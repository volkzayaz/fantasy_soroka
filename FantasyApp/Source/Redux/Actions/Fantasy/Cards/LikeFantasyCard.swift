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
        
        let request: Single<Void>
        switch type {
        case .dislike: request = Fantasy.Manager.dislike(card: card)
        case .like:    request = Fantasy.Manager.like(card: card)
        case .neutral: request = Fantasy.Manager.neutral(card: card)
        }
        
        return request.asObservable().flatMap { _ -> Observable<AppState> in
            
            var state = initialState
            
            ///Updating Main Deck state
            ///not neccesserily removes card
            ///could be a case that swiping stack does not contain liked\disliked card
            var deckIsConsistent = false
            if self.shouldDecrement && self.card.isFree {
                deckIsConsistent = state.fantasiesDeck.pop(card: self.card)
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
            if deckIsConsistent {
                return .just(state)
            }
            
            return Fantasy.Manager.fetchMainCards().asObservable()
                .map { cards in
                    state.fantasiesDeck = .cards(cards)
                
                    return state
                }
        }
        
    }
    
}
