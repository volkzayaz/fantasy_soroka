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
    
    var navigationContext: Fantasy.Card.NavigationContext { get }
}


protocol FantasyDetailProvider {
    
    var card: Fantasy.Card { get }
    var initialReaction: Fantasy.Card.Reaction { get }
    
    ///analytics properties defined by stakeholders
    ///this is why they are so messy
    var navigationContext: Fantasy.Card.NavigationContext { get }
    
    ///is provied automatically (beacuse of stakeholders data redundancy)
    var actionContext: Fantasy.Card.ActionContext { get }
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool
    
}

extension FantasyDetailProvider {
    var actionContext: Fantasy.Card.ActionContext {
        return .inside(navigationContext)
    }
}

struct MainDeckProvider: FantasyDeckProvier {
    
    var pessimisticReload: Bool { return false }
    
    var navigationContext: Fantasy.Card.NavigationContext {
        return .Deck
    }
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
        return appState.changesOf { $0.fantasiesDeck }
    }
    
    func swiped(card: Fantasy.Card, in direction: FantasyDeckViewModel.SwipeDirection, mutualTrigger: @escaping () -> Void) {
        
        switch direction {
        case .left:
            Dispatcher.dispatch(action: DislikeFantasy(card: card,
                                                       actionContext: .Deck))
            
        case .right:
            Dispatcher.dispatch(action: LikeFantasy(card: card,
                                                    actionContext: .Deck))
            
        case .down:
            ///don't really know what should happen here for now
            //fatalError("Implement me")
            break
            
        }
        
    }
    
    func detailsProvider(card: Fantasy.Card, reactionCallback: (() -> Void)? = nil) -> FantasyDetailProvider {
        return OwnFantasyDetailsProvider(card: card,
                                         initialReaction: .neutral,
                                         navigationContext: .Deck)
        
    }
    
};

struct RoomsDeckProvider: FantasyDeckProvier {
    
    let room: Room
    let card = BehaviorRelay<Int>(value: 0)
    
    var pessimisticReload: Bool { return true }
    
    var navigationContext: Fantasy.Card.NavigationContext {
        return .RoomPlay
    }
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
        
        card.accept(0)
        
        return appState.changesOf { $0.currentUser?.subscription }
            .flatMapLatest { _ in
                return Fantasy.Manager.fetchSwipesDeck(in: self.room)
                    .retry(2)
                    .asDriver(onErrorJustReturn: .init(cards: [],
                                                       deckState: .init(wouldBeUpdatedAt: Date(timeIntervalSince1970: 0))))
            }
            .flatMap { [unowned x = card] state -> Driver<AppState.FantasiesDeck> in
                
                return x
                    .asDriver()
                    .filter { $0 >= state.cards.count }
                    .startWith(0)
                    .map { suffix in
                        AppState.FantasiesDeck(cards: Array(state.cards.suffix(from: suffix)),
                                               wouldUpdateAt: state.deckState.wouldBeUpdatedAt)
                    }
                
            }
        
    }
    
    func swiped(card: Fantasy.Card, in direction: FantasyDeckViewModel.SwipeDirection, mutualTrigger: @escaping () -> Void) {
        
        switch direction {
        case .right:
            _ = Fantasy.Manager.like(card: card, in: room, actionContext: .RoomDeck)
                .subscribe(onSuccess: { x in
                    if x.isMutual { mutualTrigger() }
                })
            
        case .left:
            _ = Fantasy.Manager.dislike(card: card, in: room, actionContext: .RoomDeck)
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
                                          reactionCallback: reactionCallback,
                                          navigationContext: .RoomPlay)
    }
    
}

struct OwnFantasyDetailsProvider: FantasyDetailProvider {
    
    let card: Fantasy.Card
    let initialReaction: Fantasy.Card.Reaction
    let navigationContext: Fantasy.Card.NavigationContext
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool {
        
        switch reaction {
        case .like   : Dispatcher.dispatch(action: LikeFantasy(card: card,
                                                               actionContext: actionContext))
        case .dislike: Dispatcher.dispatch(action: DislikeFantasy(card: card,
                                                                  actionContext: actionContext))
            
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
    let navigationContext: Fantasy.Card.NavigationContext
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool {
        
        switch reaction {
        case .like:
            _ = Fantasy.Manager.like(card: card,
                                     in: room,
                                     actionContext: actionContext)
                .subscribe()
            
        case .dislike:
            _ = Fantasy.Manager.dislike(card: card,
                                        in: room,
                                        actionContext: actionContext)
                .subscribe()
            
        case .block, .neutral: return false;
            
        }
     
        reactionCallback?()
        
        return true
    }
    
}
