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
    
    var actionButtonTitle: Driver<String> {
        
        return reloadTrigger.asDriver(onErrorJustReturn: ())
            .flatMapLatest { _ -> Driver<String> in
                let collection = self.collection
                
                if collection.isAvailable { return .just("Open") }
                
                if let x = collection.productId, RemoteConfigManager.showPriceInDeck {
                    return SwiftyStoreKit.rx_productDetails(products: [x])
                        .map { $0.first! }
                        .map { "\($0.localizedPrice)" }
                        .asDriver(onErrorJustReturn: "error")
                }
                
                return .just(R.string.localizable.paymentGet())
                
            }
        
    }
    
    ///if collection is not purchased, there only will be a single card inside
    var availableCards: Driver<[Fantasy.Card]> {
        return Fantasy.Manager.fetchCollectionsCards(collection: collection)
            .asDriver(onErrorJustReturn: [])
    }
    
    var purchaseAvailable: Bool {
        return !collection.isAvailable
    }
    
    var collectionPurchased: Bool {
        return collection.isIAPPurchased || appStateSlice.currentUser?.fantasies.purchasedCollections.contains(where: { $0.id == collection.id }) ?? false
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

class FantasyCollectionDetailsViewModel : MVVM_ViewModel {
    
    let collection: Fantasy.Collection
    
    let reloadTrigger = BehaviorSubject<Void>( value: () )
    
    let collectionPickedAction: CollectionPicked?
    
    private var timeSpentCounter = TimeSpentCounter()
    private let context: Analytics.Event.CollectionViewed.NavigationContext
    
    init(router: FantasyCollectionDetailsRouter,
         collection: Fantasy.Collection,
         collectionPickedAction: CollectionPicked?,
         context: Analytics.Event.CollectionViewed.NavigationContext) {
        self.router = router
        self.collection = collection
        self.context = context
        self.collectionPickedAction = collectionPickedAction
        
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
                    deckOffer: offer,
                    completion: {
                        self.reloadTrigger.onNext( () )
                }
                )
            }
        }
    }
}

extension FantasyCollectionDetailsViewModel {
    
    func buy() {
        
        if collection.isAvailable, let x = collectionPickedAction {
            return x(collection)
        }
        
        if collection.isAvailable {
            Analytics.report(Analytics.Event.DraftRoomCreated())
            
            RoomManager.createDraftRoom(collections: [collection.id])
                .trackView(viewIndicator: indicator)
                .silentCatch(handler: router.owner)
                .subscribe(onNext: { [unowned self] room in
                    self.router.showRoom(room)
                })
                .disposed(by: bag)
            return
        }
        
        if let productId = collection.productId {
            PurchaseManager.purhcaseCollection(with: productId)
                .trackView(viewIndicator: indicator)
                .subscribe(onNext: { _ in
                    Dispatcher.dispatch(action: BuyCollection(collection: self.collection))
                    self.reloadTrigger.onNext( () )
                    
                    if let x = self.collectionPickedAction {
                        x(self.collection)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.buy() ///automatically open collection
                        }
                    }
                    
                }, onError: { [weak o = router.owner] error in
                    self.openOfferIfNeeded(for: .promo)
                    o?.present(error: error)
                })
                .disposed(by: bag)
            return;
        }
        
        router.showSubscription { [weak t = reloadTrigger] in
            t?.onNext( () )
            
            self.collectionPickedAction?(self.collection)
        }
        
    }
    
    func share() {
        buo = collection.share(presenter: router.owner)
    }
    
    func viewAppeared() {
        timeSpentCounter.start()
        openOfferIfNeeded(for: .special)
    }
    
    func viewWillDisappear() {
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
