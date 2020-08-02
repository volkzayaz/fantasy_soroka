//
//  DeckLimitedOfferViewModel.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 20.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftyStoreKit

struct DeckLimitedOfferViewModel : MVVM_ViewModel {
    
    enum OfferType {
        case promo, special
    }
    
    let offerType: OfferType
    let collection: Fantasy.Collection
    let deckOffer: CollectionOffer.Offer
    let router: DeckLimitedOfferRouter
    
    private let indicator: ViewIndicator = ViewIndicator()
    private let bag = DisposeBag()
    private let completion: (() -> Void)?
    
    init(
        router: DeckLimitedOfferRouter,
        offerType: OfferType,
        collection: Fantasy.Collection,
        deckOffer: CollectionOffer.Offer,
        completion: (() -> Void)? = nil
    ) {
        self.router = router
        self.offerType = offerType
        self.collection = collection
        self.completion = completion
        self.deckOffer = deckOffer
        
        /////progress indicator
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
}

extension DeckLimitedOfferViewModel {
    
    var offer: Driver<DeckOffer?> {
        let ids = Set(arrayLiteral: deckOffer.currentDeck, deckOffer.specialDeck)
        let offerType = self.offerType
        let analyticsName = deckOffer.specialAnalyticsName
        
        return SwiftyStoreKit.rx_productDetails(products: ids)
            .retry(1)
            .trackView(viewIndicator: indicator)
            .map { products in
                guard products.count == 2 else { return nil }
                
                let sortedProducts = products
                    .sorted(by: { $0.price.doubleValue < $1.price.doubleValue })
                
                return DeckOffer(
                    product: sortedProducts[0],
                    defaultProduct: sortedProducts[1],
                    analyticsName: analyticsName,
                    offerType: offerType
                )
        }
        .asDriver(onErrorJustReturn: nil)
    }
}

extension DeckLimitedOfferViewModel {
    
    func subscribe(plan: DeckOffer) {
        let copy = self.completion
        
        PurchaseManager.purhcaseCollection(with: plan.productId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned o = router.owner] _ in
                Dispatcher.dispatch(action: BuyCollection(collection: self.collection))

                o.dismiss(animated: true, completion: {
                    copy?()
                })
            })
            .disposed(by: self.bag)
    }
}


struct DeckOffer {
    let price: NSAttributedString
    let name: String
    let productId: String
    let savePercent: Int
    let analyticsName: String
    
    init(product: SKProduct, defaultProduct: SKProduct, analyticsName: String, offerType: DeckLimitedOfferViewModel.OfferType) {
        self.name = product.localizedTitle
        self.productId = product.productIdentifier
        self.analyticsName = analyticsName
        
        let priceAttr = NSMutableAttributedString()
        priceAttr.append(
            ((offerType == .promo ? R.string.localizable.deckLimitedOfferTitle() : R.string.localizable.deckOnetimeOfferTitle()) + "\n").toAttributed(
                with: .systemFont(ofSize: 15, weight: .regular),
                alignment: .center,
                color: R.color.textBlackColor() ?? .black
            )
        )
        priceAttr.append(
            R.string.localizable.subscriptionLimitedOfferFor().toAttributed(
                with: .systemFont(ofSize: 15, weight: .medium),
                alignment: .center,
                color: R.color.textBlackColor() ?? .black
            )
        )
        
        priceAttr.append(
            defaultProduct.localizedPrice.toAttributed(
                with: .systemFont(ofSize: 15, weight: .medium),
                alignment: .center,
                color: R.color.textLightGrayColor() ?? .black,
                strikethroughStyle: .single,
                strikethroughColor: R.color.textLightGrayColor() ?? .black
            )
        )
        
        priceAttr.append(
            "  \(product.localizedPrice)".toAttributed(
                with: .systemFont(ofSize: 22, weight: .bold),
                alignment: .center,
                color: R.color.textPinkColor() ?? .black
            )
        )
        
        price = priceAttr
        savePercent = 100 - Int((product.price.doubleValue / defaultProduct.price.doubleValue) * 100)
    }
}
