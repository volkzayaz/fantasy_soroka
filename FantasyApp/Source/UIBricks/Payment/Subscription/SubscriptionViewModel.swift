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
    
    let productID: String
    let type: SubscriptionPlanType
    let title: String
    let payment: String
    let details: NSAttributedString
    let buttonTitle: String
    let sticker: String?
    let position: Int
    let analyticsDescription: String
    
    init?(configuration: SubscriptionPlanConfiguration, product: SKProduct, baseProduct: SKProduct?) {
        guard let position = configuration.position else { return nil }
        
        productID = product.productIdentifier
        type = configuration.type
        title = configuration.title(product: product)
        payment = configuration.payment(product: product)
        details = configuration.details(product: product, baseProduct: baseProduct)
        buttonTitle = configuration.localizedButtonTitle
        sticker = configuration.sticker(product: product, baseProduct: baseProduct)
        self.position = position
        
        analyticsDescription = "P\(position)_" + product.shortSubscriptionPeriodDuration + type.rawValue.capitalizingFirstLetter() + "\(product.price.stringValue)"
    }
}

extension SubscriptionViewModel {
    
    enum Page: Int, CaseIterable {
        case x3NewProfilesDaily = 0
        case globalMode
        case changeActiveCity
        case accessToAllDecks
        case x3NewCardsDaily
        case unlimitedRooms
        case memberBadge
        
        var purchaseInterestContext: Analytics.Event.PurchaseInterest.Context {
            switch self {
            case .x3NewProfilesDaily:
                return .x3NewProfilesDaily
            case .globalMode:
                return .globalMode
            case .changeActiveCity:
                return .changeActiveCity
            case .accessToAllDecks:
                return .accessToAllDecks
            case .x3NewCardsDaily:
                return .x3NewCardsDaily
            case .unlimitedRooms:
                return .unlimitedRooms
            case .memberBadge:
                return .memberBadge
            }
        }
    }

    var plans: Driver<[SubscriptionPlan]> { plansRelay.asDriver() }
    var showAllPlans: Driver<Bool> { showAllPlansRelay.asDriver() }
}

class SubscriptionViewModel : MVVM_ViewModel {
    
    let startPage: Page
    let screenTitle: String
    let style: SubscriptionPlansStyle
    
    private let plansRelay = BehaviorRelay<[SubscriptionPlan]>(value: [])
    private let showAllPlansRelay = BehaviorRelay<Bool>(value: false)
    private let completion: (() -> Void)?
    
    init(router: SubscriptionRouter, page: Page? = nil, completion: ( () -> Void)? = nil ) {
        self.router = router
        startPage = page ?? Page.allCases[0]
        self.completion = completion
        screenTitle = RemoteConfigManager.subscriptionPlansConfiguration.localizedScreenTitle
        style = RemoteConfigManager.subscriptionPlansConfiguration.style
        
        let configurations = RemoteConfigManager.subscriptionPlansConfiguration.plans
        let ids = configurations.reduce([]) { (result, configuration) -> Set<String> in
            var newResult = result
            newResult.insert(configuration.productId)
            if let baseProductId = configuration.baseProductId {
                newResult.insert(baseProductId)
            }
            
            return newResult
        }

        SwiftyStoreKit.rx_productDetails(products: ids)
            .retry(1)
            .trackView(viewIndicator: indicator)
            .map { products in
                return configurations.compactMap { configuration -> SubscriptionPlan? in
                    guard let product = products.first(where: { $0.productIdentifier == configuration.productId }) else { return nil }
                    
                    var baseProduct: SKProduct?
                    if let baseProductId = configuration.baseProductId {
                        baseProduct = products.first { $0.productIdentifier == baseProductId }
                    }

                    return SubscriptionPlan(configuration: configuration, product: product, baseProduct: baseProduct)
                }.sorted { $0.position < $1.position }
            }.asDriver(onErrorJustReturn: [])
            .drive(plansRelay)
            .disposed(by: bag)
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
        
        NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
            .subscribe { [unowned self] _ in self.reportPurchaseInterest(paymentStatus: .terminate) }
            .disposed(by: bag)
        NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
            .subscribe { [unowned self] _ in
                guard !isPurchaseInProgress else { return }
                self.reportPurchaseInterest(paymentStatus: .resignActive)
            }.disposed(by: bag)
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe { [unowned self] _ in
                guard !isPurchaseInProgress else { return }
                self.timeSpentCounter.restart()
            }.disposed(by: bag)
        
        timeSpentCounter.start()
    }
    
    let router: SubscriptionRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    private var timeSpentCounter = TimeSpentCounter()
    private var isPurchaseInProgress = false
}

extension SubscriptionViewModel {
    
    func seeOtherPlans() {
        showAllPlansRelay.accept(true)
    }
    
    func subscribe(planIndex: Int) {
        guard let plan = plansRelay.value[safe: planIndex] else { return }
        let copy = self.completion
        
        isPurchaseInProgress = true
        PurchaseManager.purhcaseSubscription(with: plan.productID)
            .trackView(viewIndicator: indicator)
            .catchError { [unowned self] error in
                self.reportPurchaseInterest(paymentStatus: .failed)
                self.timeSpentCounter.restart()
                throw error
            }.silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self, o = router.owner] _ in
                self.reportPurchaseInterest(paymentStatus: .success)
                o.dismiss(animated: true, completion: {
                    copy?()
                })
            }, onCompleted: { [unowned self] in
                self.isPurchaseInProgress = false
            }).disposed(by: self.bag)
    }
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
    func willCancel() {
        reportPurchaseInterest(paymentStatus: .cancel)
    }
}

private extension SubscriptionViewModel {
    
    func reportPurchaseInterest(paymentStatus: Analytics.Event.PurchaseInterest.PaymentStatus) {
        guard timeSpentCounter.isStarted else { return }
        
        Analytics.report(Analytics.Event.PurchaseInterest(context: startPage.purchaseInterestContext, content: purchaseInterestEventContent, type: .regular, paymentStatus: paymentStatus, spentTime: timeSpentCounter.finish()))
    }
    
    var purchaseInterestEventContent: String {
        plansRelay.value.map { $0.analyticsDescription }.joined(separator: " ") + " Style\(style.rawValue)" + " PlansVisible_\(showAllPlansRelay.value ? "Yes" : "No")"
    }
}
