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
            protectPolicy,
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
    fileprivate let protectPolicy: Driver<Bool>
    fileprivate let detailsProvider: (Fantasy.Card) -> FantasyDetailProvider
    
    let title: String
    
    let animator = FantasyDetailsTransitionAnimator()
    
    init(router: FantasyListRouter,
         detailsProvider: @escaping (Fantasy.Card) -> FantasyDetailProvider,
         cards: [Fantasy.Card]) {
        self.init(router: router,
                  cardsProvider: .just(cards),
                  detailsProvider: detailsProvider,
                  title: "")
    }
    
    init(router: FantasyListRouter,
         cardsProvider: Driver<[Fantasy.Card]>,
         detailsProvider: @escaping (Fantasy.Card) -> FantasyDetailProvider,
         title: String,
         protectPolicy: Driver<Bool> = .just(false)) {
        self.router = router
        self.provider = cardsProvider
        self.detailsProvider = detailsProvider
        self.protectPolicy = protectPolicy
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
        
        router.cardTapped(provider: detailsProvider(card) )
    }
}
