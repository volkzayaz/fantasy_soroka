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

extension FantasyCollectionDetailsViewModel {
    
    var price: Driver<String> {

        return SwiftyStoreKit.rx_productDetails(products: [collection.productId!])
            .map { $0.first! }
            .map { "\($0.localizedPrice)" }
            .asDriver(onErrorJustReturn: "error")
            
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
    
}

struct FantasyCollectionDetailsViewModel : MVVM_ViewModel {
    
    let collection: Fantasy.Collection
    
    let reloadTrigger = BehaviorSubject<Void>( value: () )
    
    private var timeSpentCounter = TimeSpentCounter()
    private let context: Analytics.Event.CollectionViewed.NavigationContext
    
    var deatilsCollapsed: Bool = false
    var highlightsCollapsed: Bool = false
    var loveThisCollapsed: Bool = false
    
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
}

extension FantasyCollectionDetailsViewModel {
    
    func buy() {
        
        if collectionPurchased {
            router.showCollection(collection: collection)
            return;
        }
        
        PurchaseManager.purhcase(collection: collection)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [weak o = router.owner] in
                Dispatcher.dispatch(action: BuyCollection(collection: self.collection))
                
                self.reloadTrigger.onNext( () )
                
            })
            .disposed(by: bag)
        
    }
    
    mutating func share() {
        buo = collection.share(presenter: router.owner)
    }
    
    mutating func viewAppeared() {
        timeSpentCounter.start()
    }
    
    mutating func viewWillDisappear() {
        
        Analytics.report(Analytics.Event.CollectionViewed(collection: collection,
                                                          context: context,
                                                          spentTime: timeSpentCounter.finish()))
        
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
