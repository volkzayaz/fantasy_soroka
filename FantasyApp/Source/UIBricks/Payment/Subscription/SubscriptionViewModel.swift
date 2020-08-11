//
//  SubscriptionViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import SwiftyStoreKit

struct SubscriptionOffer {
    let plan: SubscriptionPlan
    let discount: String?
    
    init (plan: SubscriptionPlan, compare: NSDecimalNumber?) {
        
        self.plan = plan
        
        guard let x = compare else { self.discount = ""; return }
        
        let y = NSDecimalNumber(integerLiteral: 1)
        let x1 = plan.dailyDecimal.dividing(by: x)
        let x2 = y.subtracting(x1)
        let x3 = x2.multiplying(by: 100)
        let res = x3.int8Value
        
        discount = "\(res)%"
        
    }
}

extension Int {
    
    ///Method returns countable string based on amount of number for given noun
    ///If self == 1 than it would return "1 apple"
    ///But if self == 3 => "3 apples"
    func countableString(withSingularNoun noun: String) -> String {
        
        if self == 1 {
            return "\(self) \(noun)"
        }
        
        return "\(self) \(noun)s"
        
    }
}

struct SubscriptionPlan {
    
    let price: String
    let duration: String
    let dailyDecimal: NSDecimalNumber
    let dailyCharge: String
    let productId: String
    
    init(product: SKProduct) {
        
        price = product.localizedPrice
        productId = product.productIdentifier
        
        guard let p = product.subscriptionPeriod else {
            duration = ""
            dailyCharge = ""
            dailyDecimal = 0
            return
        }
        
        switch p.unit {
        case .day: duration = p.numberOfUnits.countableString(withSingularNoun: "day")
        case .month: duration = p.numberOfUnits.countableString(withSingularNoun: "month")
        case .week: duration = p.numberOfUnits.countableString(withSingularNoun: "week")
        case .year: duration = p.numberOfUnits.countableString(withSingularNoun: "year")
        }
        
        var divider: Int = p.numberOfUnits
        
        switch p.unit {
        case .day: divider *= 1
        case .month: divider *= 30
        case .week: divider *= 7
        case .year: divider *= 365
        }
        
        dailyDecimal = product.price.dividing(by: NSDecimalNumber(integerLiteral: divider))
        
        let formatter = SKProduct.formatter
        formatter.locale = product.priceLocale
        
        let dailyCharge = formatter.string(from: dailyDecimal) ?? ""
        self.dailyCharge = R.string.localizable.subscriptionDailyCharge(dailyCharge)
    }
    
}

extension SubscriptionViewModel {
    
    enum Page: Int {
        case unlimRooms = 0
        case fantasyX3
        case teleport
        case member
        case subscriptionOffer
    }

    var offers: Driver<[SubscriptionOffer]> {
        
        let ids = immutableNonPersistentState.subscriptionProductIDs ?? premiumIds
        
        return SwiftyStoreKit.rx_productDetails(products: ids)
            .retry(1)
            .trackView(viewIndicator: indicator)
            .map { x in
            
                guard x.count > 2 else {
                    return []
                }
                
                let res =
                x.map(SubscriptionPlan.init)
                    .sorted { (rhs, lhs) -> Bool in
                        return rhs.dailyDecimal.compare(lhs.dailyDecimal) == .orderedDescending
                    }
                
                let mostExpensive = res[0]
                let middle = res[1]
                let cheapest = res[2]
                
                return [ SubscriptionOffer(plan: cheapest, compare: mostExpensive.dailyDecimal),
                         SubscriptionOffer(plan: mostExpensive, compare: nil),
                         SubscriptionOffer(plan: middle, compare: mostExpensive.dailyDecimal)
                ]
            }
            .asDriver(onErrorJustReturn: [])
        
    }
    
}

struct SubscriptionViewModel : MVVM_ViewModel {
    
    let startPage: Page
    private let completion: (() -> Void)?
    
    init(router: SubscriptionRouter, page: Page, completion: ( () -> Void)? = nil ) {
        self.router = router
        startPage = page
        self.completion = completion
        
        Analytics.report(Analytics.Event.PurchaseInterest(context: page))
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: SubscriptionRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension SubscriptionViewModel {
    
    func subscribe(offer: SubscriptionOffer) {
        
        let copy = self.completion
        
        PurchaseManager.purhcaseSubscription(with: offer.plan.productId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned o = router.owner] _ in
                o.dismiss(animated: true, completion: {
                    copy?()
                })
            })
            .disposed(by: self.bag)
        
    }
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}

