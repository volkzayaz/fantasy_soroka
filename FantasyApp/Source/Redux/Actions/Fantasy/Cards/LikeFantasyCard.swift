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
    let actionContext: Fantasy.Card.ActionContext
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .like, shouldDecrement: true, card: card, actionContext: actionContext)
            .perform(initialState: initialState)
    }
    
}

struct DislikeFantasy: ActionCreator {
    let card: Fantasy.Card
    let actionContext: Fantasy.Card.ActionContext
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .dislike, shouldDecrement: true, card: card, actionContext: actionContext)
            .perform(initialState: initialState)
    }
}

struct NeutralFantasy: ActionCreator {
    let card: Fantasy.Card
    let actionContext: Fantasy.Card.ActionContext
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .neutral, shouldDecrement: false, card: card, actionContext: actionContext)
            .perform(initialState: initialState)
    }
}

struct BlockFantasy: ActionCreator {
    let card: Fantasy.Card
    let actionContext: Fantasy.Card.ActionContext
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return FantasyCardInteraction(type: .block, shouldDecrement: true, card: card, actionContext: actionContext)
            .perform(initialState: initialState)
    }
}

struct FantasyCardInteraction: ActionCreator {
   
    enum InteractionType {
        case like
        case neutral
        case dislike
        case block
    }
    
    let type: InteractionType
    let shouldDecrement: Bool
    let card: Fantasy.Card
    let actionContext: Fantasy.Card.ActionContext
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        let request: Single<Void>
        switch type {
        case .dislike: request = Fantasy.Manager.dislike(card: card, actionContext: actionContext)
        case .like:    request = Fantasy.Manager.like(card: card, actionContext: actionContext)
        case .neutral: request = Fantasy.Manager.neutral(card: card, actionContext: actionContext)
        case .block:   request = Fantasy.Manager.block(card: card, actionContext: actionContext)
        }
        
        return request.asObservable().flatMap { _ -> Observable<AppState> in
            
            var state = initialState
            
            ///Updating Main Deck state
            ///not neccesserily removes card
            ///could be a case that swiping stack does not contain liked\disliked card
            var deckIsConsistent = false
            if self.shouldDecrement {
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
                
            case .block: fallthrough
            case .neutral: break
            }
            
            ///Performing Smart Refresh of Main Deck
            let weDontKnowDate = state.fantasiesDeck.wouldUpdateAt == nil
            
            let wouldWeGetNewInfo = (weDontKnowDate && self.card.isFree)
            
            if deckIsConsistent && !wouldWeGetNewInfo {
                return .just(state)
            }
            
            return Fantasy.Manager.fetchSwipesDeck().asObservable()
                .map { deck in
                    state.fantasiesDeck = deck
                
                    return state
                }
        }
        
    }
    
}

///https://trello.com/c/cDizL9vu/161-rooms-swipe
struct LikeRoomCardLogic: Action {
    
    let card: Fantasy.Card
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        state.fantasiesDeck.pop(card: card)
        
        return state
    }
    
}
