//
//  FantasyCollectionDetailsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/30/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import SwiftyStoreKit

import RxSwift
import RxCocoa
import Branch
import RxDataSources

extension FantasyCollectionDetailsViewModel {
    
    var price: Driver<String> {
        if RemoteConfigManager.showPriceInDeck {
            return SwiftyStoreKit.rx_productDetails(products: [collection.productId!])
                .map { $0.first! }
                .map { "\($0.localizedPrice)" }
                .asDriver(onErrorJustReturn: "error")
        } else {
            return Observable.just(R.string.localizable.paymentGet())
                .asDriver(onErrorJustReturn: "")
        }
    }
    
    ///if collection is not purchased, there only will be a single card inside
    var availableCards: Driver<[Fantasy.Card]> {
        return Fantasy.Manager.fetchCollectionsCards(collection: collection)
            .asDriver(onErrorJustReturn: [])
    }
    
    var purchaseAvailable: Bool {
        return !collection.isPurchased
    }
    
    var collectionPurchased: Bool {
        return collection.isPurchased || appStateSlice.currentUser?.fantasies.purchasedCollections.contains(where: { $0.id == collection.id }) ?? false
    }
    
    var dataSource: Driver<[SectionModel<String, Model>]> {
        
        let x = collection
        
        var result: [SectionModel<String, Model>] = [
            SectionModel(model: "top",
                         items: [.top])
        ]
        
        if let t = x.customBlock {
            result.append(.init(model: "Custom Block",
                                items: [.expandable(title: t.title, description: t.description)]))
        }
        
        if x.details.count > 0 {
            result.append(.init(model: "Details",
                                items: [.expandable(title: R.string.localizable.fantasyCollectionDetails(), description: x.details)]))
        }
        
        result.append(.init(model: "What's inside",
                            items: [.whatsInside]))
        
        if x.highlights.count > 0 {
            result.append(.init(model: "Highlights",
                                items: [.expandable(title: R.string.localizable.fantasyCollectionHighlights(), description: x.highlights)]))
        }
        
        if x.loveThis.count > 0 {
            result.append(.init(model: "LoveThis",
                                items: [.expandable(title: R.string.localizable.fantasyCollectionYouWillLove(), description: x.loveThis)]))
        }
        
        if let t = x.author {
            result.append(.init(model: "Author",
                                items: [.author]))
        }
        
        result.append(.init(model: "Bottom", items: [.bottom]))
        result.append(.init(model: "Share", items: [.share]))
        
        return .just(result)
    }
    
}

struct FantasyCollectionDetailsViewModel : MVVM_ViewModel {
    
    let collection: Fantasy.Collection
    
    let reloadTrigger = BehaviorSubject<Void>( value: () )
    
    private var timeSpentCounter = TimeSpentCounter()
    private let context: Analytics.Event.CollectionViewed.NavigationContext
    
    init(router: FantasyCollectionDetailsRouter,
         collection: Fantasy.Collection,
         context: Analytics.Event.CollectionViewed.NavigationContext) {
        self.router = router
        self.collection = collection
        self.context = context
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyCollectionDetailsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    private var buo: BranchUniversalObject!
    
    enum Model {
        case top
        case expandable(title: String, description: String)
        case whatsInside
        case author
        case bottom
        case share
    }
    
    var expanded: [String: Bool] = [:]
    
    private func openOfferIfNeeded(for offerType: DeckLimitedOfferViewModel.OfferType) {
        let decksOffer = offerType == .special ? RemoteConfigManager.specialDecksOffer : RemoteConfigManager.priceDecksOffer
        
        guard let deckOffer = decksOffer.first(where: { $0.id == collection.id }), collectionPurchased == false else {
            return
        }
        let offers = deckOffer.deckOffers.filter { $0.isEnabled }
        
        offers.forEach { offer in
            PerformManager.perform(rule: .on(offer.triggerCount), event: .customName(offer.name.replacingOccurrences(of: " ", with: ""))) {
                self.router.presentDeckLimitedOffer(
                    offerType: offerType,
                    collection: collection,
                    deckOffer: offer
                )
            }
        }
    }
}

extension FantasyCollectionDetailsViewModel {
    
    func buy() {
        if collectionPurchased {
            router.showCollection(collection: collection)
            return;
        }
        
        SwiftyStoreKit.rx_productDetails(products: [collection.productId!])
            .map { $0.first! }
            .subscribe(onSuccess: {
                Analytics.report(Analytics.Event.PurchaseCollectionInterest(
                    context: .collection,
                    collectionName: $0.localizedTitle,
                    isPriceVisable: RemoteConfigManager.showPriceInDeck
                    )
                )
            })
            .disposed(by: bag)
        
        PurchaseManager.purhcase(collection: collection)
            .trackView(viewIndicator: indicator)
            .subscribe(onNext: { [weak o = router.owner] _ in
                Dispatcher.dispatch(action: BuyCollection(collection: self.collection))
                
                self.reloadTrigger.onNext( () )
                }, onError: { [weak o = router.owner] error in
                    self.openOfferIfNeeded(for: .promo)
                    o?.present(error: error)
            })
            .disposed(by: bag)
    }
    
    mutating func share() {
        buo = collection.share(presenter: router.owner)
    }
    
    mutating func viewAppeared() {
        timeSpentCounter.start()
        openOfferIfNeeded(for: .special)
    }
    
    mutating func viewWillDisappear() {
        Analytics.report(
            Analytics.Event.CollectionViewed(
                collection: collection,
                context: context,
                spentTime: timeSpentCounter.finish()
            )
        )
    }
    
    func openAuthorFB() {
        
        guard let src = collection.author?.srcFb,
            let url = URL(string: src) else {
                return
        }
        
        router.showSafari(for: url)
        
    }
    
    func openAuthorInsta() {
        
        guard let src = collection.author?.srcInstagram,
            let url = URL(string: src) else {
                return
        }
        
        router.showSafari(for: url)
    }
    
    func openAuthorWeb() {
        
        guard let src = collection.author?.srcWeb,
            let url = URL(string: src) else {
                return
        }
        
        router.showSafari(for: url)
    }
    
}
