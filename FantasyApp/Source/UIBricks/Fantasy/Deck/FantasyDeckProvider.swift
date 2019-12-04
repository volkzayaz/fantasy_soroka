//
//  FantasyDeckProvider.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FantasyDeckProvier {
    
    ///True -- for reload on each view appearence
    ///False -- if you can manage all state using |cardsChange|
    var pessimisticReload: Bool { get }
    
    var cardsChange: Driver<AppState.FantasiesDeck> { get }
    
    func swiped(card: Fantasy.Card,
                `in` direction: FantasyDeckViewModel.SwipeDirection,
                mutualTrigger: @escaping () -> Void) -> Void
    
    func detailsProvider(card: Fantasy.Card, reactionCallback: (() -> Void)?) -> FantasyDetailProvider
    
}

protocol FantasyDetailProvider {
    
    var card: Fantasy.Card { get }
    var initialReaction: Fantasy.Card.Reaction { get }
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool
    
}

struct MainDeckProvider: FantasyDeckProvier {

    var pessimisticReload: Bool { return false }
    
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
    
    func detailsProvider(card: Fantasy.Card, reactionCallback: (() -> Void)? = nil) -> FantasyDetailProvider {
        return OwnFantasyDetailsProvider(card: card, initialReaction: .neutral)
    }
    
};

struct RoomsDeckProvider: FantasyDeckProvier {
    
    let room: Room
    let card = BehaviorRelay<Int>(value: 0)
    
    var pessimisticReload: Bool { return true }
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
        
        card.accept(0)
        
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
    
    func detailsProvider(card: Fantasy.Card, reactionCallback: (() -> Void)?) -> FantasyDetailProvider {
        return RoomFantasyDetailsProvider(room: room,
                                          card: card,
                                          initialReaction: .neutral,
                                          reactionCallback: reactionCallback)
    }
    
}

struct OwnFantasyDetailsProvider: FantasyDetailProvider {
    
    let card: Fantasy.Card
    let initialReaction: Fantasy.Card.Reaction
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool {
        
        switch reaction {
        case .like   : Dispatcher.dispatch(action: LikeFantasy(card: card))
        case .dislike: Dispatcher.dispatch(action: DislikeFantasy(card: card))
            
        case .neutral: return false
            ///Dispatcher.dispatch(action: NeutralFantasy(card: card))
            
        case .block: return false;
            
        }
        
        return true
    }
    
}

struct RoomFantasyDetailsProvider: FantasyDetailProvider {
    
    let room: Room
    let card: Fantasy.Card
    let initialReaction: Fantasy.Card.Reaction
    let reactionCallback: (() -> Void)?
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool {
        
        switch reaction {
        case .like:
            _ = Fantasy.Manager.like(card: card, in: room)
                .subscribe()
            
        case .dislike:
            _ = Fantasy.Manager
                .dislike(card: card, in: room)
                .subscribe()
            
        case .block, .neutral: return false;
            
        }
     
        reactionCallback?()
        
        return true
    }
    
}
