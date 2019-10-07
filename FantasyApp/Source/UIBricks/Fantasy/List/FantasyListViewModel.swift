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

    var dataSource: Driver<[AnimatableSectionModel<String, Fantasy.Card>]> {
        
        return cards.map { x in
            return [AnimatableSectionModel(model: "",
                                           items: x)]
        }
            
        
    }
}

struct FantasyListViewModel : MVVM_ViewModel {
    
    fileprivate let cards: Driver<[Fantasy.Card]>
    
    init(router: FantasyListRouter, cards: [Fantasy.Card]) {
        self.init(router: router, cardsProvider: .just(cards))
    }
    
    init(router: FantasyListRouter, cardsProvider: Driver<[Fantasy.Card]>) {
        self.router = router
        self.cards = cardsProvider
        
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
    
    func cardTapped(card: Fantasy.Card) {
        router.cardTapped(card: card)
    }

    
}
