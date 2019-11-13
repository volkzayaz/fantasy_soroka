//
//  FantasyListViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension FantasyListViewModel {

    var dataSource: Driver<[AnimatableSectionModel<String, ProtectedEntity<Fantasy.Card>>]> {
        
        return Driver.combineLatest(
            User.changesOfSubscriptionStatus,
            provider
        )
        .map { isSubscribed, cards in
            
            return [AnimatableSectionModel(model: "",
                                           items:  cards.map { ProtectedEntity(entity: $0,
                                                                               isProtected: isSubscribed)})]
        }
        
    }
    
}

struct FantasyListViewModel : MVVM_ViewModel {
    
    fileprivate let provider: Driver<[Fantasy.Card]>
    let title: String
    
    let animator = FantasyDetailsTransitionAnimator()
    
    init(router: FantasyListRouter, cards: [Fantasy.Card]) {
        self.init(router: router, cardsProvider: .just(cards), title: "")
    }
    
    init(router: FantasyListRouter, cardsProvider: Driver<[Fantasy.Card]>, title: String) {
        self.router = router
        self.provider = cardsProvider
        self.title = title
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyListRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension FantasyListViewModel {
    func cardTapped(card: Fantasy.Card, sourceFrame: CGRect) {
        animator.originFrame = sourceFrame
        router.cardTapped(card: card)
    }
}
