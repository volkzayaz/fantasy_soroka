//
//  SubscriptionLimitedOfferViewModel.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 12.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftyStoreKit

class SubscriptionLimitedOfferViewModel : MVVM_ViewModel {
    
    enum OfferType {
        case promo, special
    }
    
    let router: SubscriptionLimitedOfferRouter
    let offerType: OfferType
    
    private let indicator: ViewIndicator = ViewIndicator()
    private let bag = DisposeBag()
    private let completion: (() -> Void)?
    
    init(router: SubscriptionLimitedOfferRouter, offerType: OfferType, completion: ( () -> Void)? = nil ) {
        self.router = router
        self.offerType = offerType
        self.completion = completion
        
        /////progress indicator
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
}

extension SubscriptionLimitedOfferViewModel {
    
    var offer: Driver<LimitedOffer?> {
        let offer = offerType == .promo ? RemoteConfigManager.subscriptionOfferPromo : RemoteConfigManager.subscriptionOfferSpecial
        let ids = Set(arrayLiteral: offer.currentProduct, offer.specialProduct)
        
        return SwiftyStoreKit.rx_productDetails(products: ids)
            .retry(1)
            .trackView(viewIndicator: indicator)
            .map { products in
                guard products.count == 2 else { return nil }
                
                let sortedProducts = products
                    .sorted(by: { $0.price.doubleValue < $1.price.doubleValue })
                
                return LimitedOffer(
                    product: sortedProducts[0],
                    defaultProduct: sortedProducts[1],
                    analyticsName: offer.specialAnalyticsName
                )
        }
        .asDriver(onErrorJustReturn: nil)
    }
}

extension SubscriptionLimitedOfferViewModel {
    
    func subscribe(plan: LimitedOffer) {
        let copy = self.completion
        
        PurchaseManager.purhcaseSubscription(with: plan.productId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned o = router.owner] _ in
                o.dismiss(animated: true, completion: {
                    copy?()
                })
            })
            .disposed(by: self.bag)
    }
}

struct LimitedOffer {
    let price: NSAttributedString
    let name: String
    let productId: String
    let savePercent: Int
    let analyticsName: String
    
    init(product: SKProduct, defaultProduct: SKProduct, analyticsName: String) {
        self.name = product.localizedTitle
        self.productId = product.productIdentifier
        self.analyticsName = analyticsName
        
        let priceAttr = NSMutableAttributedString()
        priceAttr.append(
            R.string.localizable.subscriptionLimitedOfferFor().toAttributed(
                with: .systemFont(ofSize: 15, weight: .medium),
                alignment: .center,
                color: R.color.textBlackColor() ?? .black
            )
        )
        
        priceAttr.append(
            "\(defaultProduct.localizedPrice) ".toAttributed(
                with: .systemFont(ofSize: 15, weight: .medium),
                alignment: .center,
                color: R.color.textLightGrayColor() ?? .black,
                strikethroughStyle: .single,
                strikethroughColor: R.color.textLightGrayColor() ?? .black
            )
        )
        
        priceAttr.append(
            product.localizedPrice.toAttributed(
                with: .systemFont(ofSize: 22, weight: .bold),
                alignment: .center,
                color: R.color.textPinkColor() ?? .black
            )
        )
        
        price = priceAttr
        savePercent = 100 - Int((product.price.doubleValue / defaultProduct.price.doubleValue) * 100)
    }
}
