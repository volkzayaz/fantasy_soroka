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
    var preferenceEnabled: Bool { get }
    
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
    
    init() {
        
        appState.map { $0.fantasiesDeck }
            .asObservable()
            .continousDeck(refreshSignal: Fantasy.Manager.fetchSwipesDeck())
            .subscribe(onNext: { deck in
                Dispatcher.dispatch(action: ResetSwipeDeck(deck: deck))
            })
            .disposed(by: bag)
        
    }
    
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
                                         navigationContext: .Deck,
                                         preferenceEnabled: true)
        
    }
    
    private let bag = DisposeBag()
    
};

private let roomsDeck = BehaviorRelay<AppState.FantasiesDeck?>(value: nil)

struct RoomsDeckProvider: FantasyDeckProvier {
    
    
    let room: Room
    
    init(room: Room) {

        self.room = room

        roomsDeck.accept(nil)
        
//        roomsDeck.notNil()
//            .startWith(.init(cards: nil, wouldUpdateAt: nil))
//            .continousDeck(refreshSignal: Fantasy.Manager.fetchSwipesDeck(in: room))
//            .bind(to: roomsDeck)
//            .disposed(by: bag)
//        
    }
    
    private let bag = DisposeBag()
    
    var navigationContext: Fantasy.Card.NavigationContext {
        return .RoomPlay
    }
    
    var cardsChange: Driver<AppState.FantasiesDeck> {
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
    let preferenceEnabled: Bool
    
    func shouldReact(to reaction: Fantasy.Card.Reaction) -> Bool {
        
        switch reaction {
        case .like   : Dispatcher.dispatch(action: LikeFantasy(card: card,
                                                               actionContext: actionContext))
        case .dislike: Dispatcher.dispatch(action: DislikeFantasy(card: card,
                                                                  actionContext: actionContext))
        
        case .block: Dispatcher.dispatch(action: BlockFantasy(card: card,
                                                              actionContext: actionContext))
            
        case .neutral: return false
            ///Dispatcher.dispatch(action: NeutralFantasy(card: card))
        
            
        }
        
        return true
    }
    
}

struct RoomFantasyDetailsProvider: FantasyDetailProvider {
    
    var preferenceEnabled: Bool {
        return true
    }
    
    let room: RoomIdentifier
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

extension Observable where Element == AppState.FantasiesDeck {
    
    func continousDeck( refreshSignal: Single<AppState.FantasiesDeck> ) -> Observable<AppState.FantasiesDeck> {
        
        return self
        .filter { deck -> Bool in
            guard let d = deck.cards else {
                return true
            }
            
            return d.count == 0
        }
        .flatMapLatest { deck -> Single<AppState.FantasiesDeck> in

            guard let fd = deck.wouldUpdateAt else {
                return refreshSignal
            }
            
            let t0 = Int(fd.timeIntervalSinceNow)
            
            let refreshStartAt: Int = t0 - 30
            
            return Single.just(0)
                .delay( .seconds(refreshStartAt) , scheduler: MainScheduler.instance)
                .flatMap { _ in
                    
                    let deliverAt: Int = Int(fd.timeIntervalSinceNow)
                    
                    return refreshSignal
                        .delay( .seconds(deliverAt), scheduler: MainScheduler.instance)
                }
                
        }
        
    }
    
}
