//
//  FantasyDeckProvider.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxCocoa

protocol FantasyDeckProvier {
    
    var cardsChange: Driver<AppState.FantasiesDeck> { get }
    
    func swiped(card: Fantasy.Card,`in` direction: FantasyDeckViewModel.SwipeDirection, mutualTrigger: @escaping () -> Void) -> Void
    
}

struct MainDeckProvider: FantasyDeckProvier {

    var cardsChange: Driver<AppState.FantasiesDeck> {
        return appState.changesOf { $0.fantasiesDeck }
    }
    
    func swiped(card: Fantasy.Card, in direction: FantasyDeckViewModel.SwipeDirection, mutualTrigger: @escaping () -> Void) {
        
        switch direction {
        case .left:
            Dispatcher.dispatch(action: DislikeFantasy(card: card))
            
        case .right:
            Dispatcher.dispatch(action: LikeFantasy(card: card))
            
        case .down:
            ///don't really know what should happen here for now
            //fatalError("Implement me")
            break
            
        }
        
    }
    
};

struct RoomsDeckProvider: FantasyDeckProvier {
    
    let room: Room
    let card = BehaviorRelay<Int>(value: 0)
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
        
        return Fantasy.Manager.fetchSwipesDeck(in: room)
            .retry(2)
            .asDriver(onErrorJustReturn: .init(cards: [],
                                               deckState: .init(wouldBeUpdatedAt: Date(timeIntervalSince1970: 0))))
            .flatMap { [unowned x = card] state -> Driver<AppState.FantasiesDeck> in
                
                return x
                    .asDriver()
                    .filter { $0 >= state.cards.count }
                    .map { _ in .empty(till: state.deckState.wouldBeUpdatedAt) }
                    .startWith( .cards(state.cards) )
                
            }
        
    }
    
    func swiped(card: Fantasy.Card, in direction: FantasyDeckViewModel.SwipeDirection, mutualTrigger: @escaping () -> Void) {
        
        switch direction {
        case .right:
            _ = Fantasy.Manager.like(card: card, in: room)
                .subscribe(onSuccess: { x in
                    if x.isMutual { mutualTrigger() }
                })
            
        case .left:
            _ = Fantasy.Manager.dislike(card: card, in: room)
                .subscribe()
            
        case .down:
            ///don't really know what should happen here for now
            //fatalError("Implement me")
            break
            
        }
        
        var x = self.card.value
        x+=1
        self.card.accept(x)
        
    }
    
}
