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
    
    var cardsChange: Driver<AppState.FantasiesDeck> { get }
    
    func swiped(card: Fantasy.Card,
                `in` direction: FantasyDeckViewModel.SwipeDirection,
                mutualTrigger: @escaping () -> Void) -> Void
    
    func detailsProvider(card: Fantasy.Card) -> FantasyDetailProvider
    
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
    
    func detailsProvider(card: Fantasy.Card) -> FantasyDetailProvider {
        return OwnFantasyDetailsProvider(card: card,
                                         initialReaction: .neutral,
                                         navigationContext: .Deck)
        
    }
    
};

private let roomsDeck = BehaviorRelay<AppState.FantasiesDeck?>(value: nil)

struct RoomsDeckProvider: FantasyDeckProvier {
    
    let room: Room
    
    private let bag = DisposeBag()
    
    var navigationContext: Fantasy.Card.NavigationContext {
        return .RoomPlay
    }
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
        
        roomsDeck.accept(nil)
        
        Fantasy.Manager.fetchSwipesDeck(in: room)
            .retry(2)
            .map { x in
                AppState.FantasiesDeck(cards: x.cards,
                                       wouldUpdateAt: x.deckState.wouldBeUpdatedAt)
            }
            .asObservable()
            .bind(to: roomsDeck)
            .disposed(by: bag)
        
        return roomsDeck.asDriver().notNil()
        
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
        
        if var deck = roomsDeck.value {
            deck.pop(card: card)
            roomsDeck.accept( deck )
        }
        
    }
    
    func detailsProvider(card: Fantasy.Card) -> FantasyDetailProvider {
        return RoomFantasyDetailsProvider(room: room,
                                          card: card,
                                          initialReaction: .neutral,
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
     
        if var deck = roomsDeck.value {
            deck.pop(card: card)
            roomsDeck.accept( deck )
        }
        
        return true
    }
    
}
