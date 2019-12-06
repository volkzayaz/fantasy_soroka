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

extension FantasyCollectionDetailsViewModel {
    
    var price: Driver<String> {

        return SwiftyStoreKit.rx_productDetails(product: collection.productId!)
            .map { "$\($0.price.stringValue)" }
            .asDriver(onErrorJustReturn: "error")
            
    }
    
    var firstCard: Driver<Fantasy.Card> {
        return Fantasy.Manager.fetchCollectionsCards(collection: collection)
            .asDriver(onErrorJustReturn: [])
            .map { $0.first! }
    }
    
}

struct FantasyCollectionDetailsViewModel : MVVM_ViewModel {
    
    let collection: Fantasy.Collection
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
    
}

extension FantasyCollectionDetailsViewModel {
    
    func buy() {
        
        PurchaseManager.purhcase(collection: collection)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [weak o = router.owner] in
                Dispatcher.dispatch(action: BuyCollection(collection: self.collection))
                //o?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
    }
    
    mutating func viewAppeared() {
        timeSpentCounter.start()
    }
    
    mutating func viewWillDisappear() {
        
        Analytics.report(Analytics.Event.CollectionViewed(collection: collection,
                                                          context: context,
                                                          spentTime: timeSpentCounter.finish()))
        
    }
    
}
