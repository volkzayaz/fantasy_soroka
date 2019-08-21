//
//  LikeFantasyCard.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct LikeFantasy: ActionCreator {
    let card: Fantasy.Card
    let shouldDecrement: Bool
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .like, shouldDecrement: shouldDecrement, card: card)
            .perform(initialState: initialState)
    }
    
}

struct DislikeFantasy: ActionCreator {
    let card: Fantasy.Card
    let shouldDecrement: Bool
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .dislike, shouldDecrement: shouldDecrement, card: card)
            .perform(initialState: initialState)
    }
}

struct NeutralFantasy: ActionCreator {
    let card: Fantasy.Card
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .neutral, shouldDecrement: false, card: card)
            .perform(initialState: initialState)
    }
}

struct FantasyCardInteraction: ActionCreator {
   
    enum InteractionType {
        case like
        case neutral
        case dislike
    }
    
    let type: InteractionType
    let shouldDecrement: Bool
    let card: Fantasy.Card
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        ///TODO: substitue for real network requests
        let request: Observable<Void>
        switch type {
        case .dislike: request = Observable.just( () )
        case .like:    request = Observable.just( () )
        case .neutral: request = Observable.just( () )
        }
        
        return request.flatMap { _ -> Observable<AppState> in
            
            var state = initialState
            
            ///Updating Main Deck state
            ///not neccesserily removes card
            ///could be a case that swiping stack does not contain liked\disliked card
            if self.shouldDecrement && self.card.isFree {
                state.fantasies.cards.removeAll { $0 == self.card }
                state.fantasies.restriction.decremet()
            }
            
            
            ///Updating User preferences
            state.currentUser?.fantasies.liked.removeAll { $0 == self.card }
            state.currentUser?.fantasies.disliked.removeAll { $0 == self.card }
            switch self.type {
            case .like:
                state.currentUser?.fantasies.liked.append(self.card)
                
            case .dislike:
                state.currentUser?.fantasies.disliked.append(self.card)
                
            case .neutral: break
            }
            
            
            ///Performing Smart Refresh of Main Deck
            guard case .swipeCount(let swipesLeft) = state.fantasies.restriction,
                  swipesLeft != state.fantasies.freeCards.count else {
                return .just(state)
            }
            
            return Fantasy.Manager.fetchMainCards(localLimit: swipesLeft).asObservable()
                .map { cards in
                    state.fantasies.cards = cards
                    state.fantasies.restriction = .swipeCount(swipesLeft)
                
                    return state
                }
        }
        
    }
    
}
