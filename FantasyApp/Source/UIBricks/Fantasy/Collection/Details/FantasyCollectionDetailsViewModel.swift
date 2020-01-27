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

        return SwiftyStoreKit.rx_productDetails(product: collection.productId!)
            .map { "$\($0.price.stringValue)" }
            .asDriver(onErrorJustReturn: "error")
            
    }
    
    ///if collection is not purchased, there only will be a single card inside
    var availableCards: Driver<[Fantasy.Card]> {
        return Fantasy.Manager.fetchCollectionsCards(collection: collection)
            .asDriver(onErrorJustReturn: [])
    }
    
}

struct FantasyCollectionDetailsViewModel : MVVM_ViewModel {
    
    let collection: Fantasy.Collection
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
        
        PurchaseManager.purhcase(collection: collection)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [weak o = router.owner] in
                Dispatcher.dispatch(action: BuyCollection(collection: self.collection))
                
                if let vc = (((o?.presentingViewController as? RootViewController)?.viewControllers.first as? MainTabBarViewController)?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? FantasyDeckViewController {
                    
                    vc.cardsTapped()
                  
                }
                
                o?.dismiss(animated: true, completion: nil)
                
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
    
}
