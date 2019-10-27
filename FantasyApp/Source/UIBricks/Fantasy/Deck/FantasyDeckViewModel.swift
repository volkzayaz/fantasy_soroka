//
//  FantasyDeckViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension FantasyDeckViewModel {
    
    enum Mode {
        case swipeCards, waiting
    }
    var mode: Driver<Mode> {
        return provider.cardsChange
            .map { state in
                
                if case .cards(_) = state {
                    return .swipeCards
                }
                return .waiting
            }
    }
    
    var timeLeftText: Driver<String> {
        
        return provider.cardsChange
            .map { x -> Date? in
                if case .empty(let date) = x {
                    return date
                }
                return nil
            }
            .notNil()
            .flatMapLatest { date in
        
                return Driver<Int>.interval(.seconds(1)).map { _ in
                    
                    let secondsTillEnd = Int(date.timeIntervalSinceNow)
                    
                    let hours   =  secondsTillEnd / 3600
                    let minutes = (secondsTillEnd % 3600) / 60
                    let seconds = (secondsTillEnd % 3600) % 60
                    
                    return "\(hours):\(minutes):\(seconds)"
                }
                
            }
        
    }
    
    var cards: Driver<[Fantasy.Card]> {
        return provider.cardsChange
            .map { deck in
                switch deck {
                case .cards(let cards): return cards
                case .empty(_): return []
                }
            }
    }
    
    var mutualCardTrigger: Driver<Fantasy.Card> {
        return cardTrigger.asDriver().notNil()
    }
    
}

struct FantasyDeckViewModel : MVVM_ViewModel {
    
    let provider: FantasyDeckProvier

    fileprivate let cardTrigger = BehaviorRelay<Fantasy.Card?>(value: nil)
    
    init(router: FantasyDeckRouter, provider: FantasyDeckProvier = MainDeckProvider()) {
        self.router = router
        self.provider = provider
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyDeckRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    

}

extension FantasyDeckViewModel {
    
    enum SwipeDirection { case left, right, down }
    func swiped(card: Fantasy.Card, direction: SwipeDirection) {
        provider.swiped(card: card, in: direction) { [unowned x = cardTrigger] in
            x.accept(card)
        }
    }
    
    func searchTapped() {
        router.searchTapped()
    }
    
    func cardTapped(card: Fantasy.Card) {
        router.cardTapped(card: card)
    }
}
