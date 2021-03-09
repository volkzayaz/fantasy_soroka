//
//  FantasyManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift

extension Fantasy {
    enum Manager {}
}

extension Fantasy.Manager {
    
    /* One of 3 options:
    1) we have new cards to show .cards([Card])
    2) we are limited for swiping til Date .waiting(Date)
    3) rarely, but some geeks might swipe through whole collection. No cards available anymore .cards( [] )
    */
    static func fetchSwipesDeck() -> Single< AppState.FantasiesDeck > {
        
        return Fantasy.Request.SwipeState()
            .rx.request
            .map { (response) in
                
                return AppState.FantasiesDeck(cards: response.cards, wouldUpdateAt: response.deckState.wouldBeUpdatedAt)
                
            }
        
    }
    
    static func searchFor(query: String) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")

        fatalErrorInDebug("Not implemented for release 1")
        
        return .just([])

    }
    
    static func fetchCollections() -> Single< [Fantasy.Collection] > {
        return Fantasy.Request.Collection().rx.request
    }
    
    static func fetchCollectionsCards(collection: Fantasy.Collection) -> Single< [Fantasy.Card] > {
        return Fantasy.Request.CollectionCards(collection: collection).rx.request
            .map { $0.availableCards }
    }
 
    static func like(card: Fantasy.Card, actionContext: Fantasy.Card.ActionContext) -> Single<Void> {
        
        print("Analytics: backend Request = Like source: \(actionContext.stakeholdersParams)")
        
        return Fantasy.Request.ReactOnCard(reaction: .like,
                                           card: card,
                                           actionContext: actionContext)
            .rx.request
            .map { _ in }
    }
    
    static func dislike(card: Fantasy.Card, actionContext: Fantasy.Card.ActionContext) -> Single<Void> {
        
        return Fantasy.Request.ReactOnCard(reaction: .dislike,
                                           card: card,
                                           actionContext: actionContext)
            .rx.request
            .map { _ in }
    }
    
    static func neutral(card: Fantasy.Card, actionContext: Fantasy.Card.ActionContext) -> Single<Void> {
        
        return Fantasy.Request.ReactOnCard(reaction: .neutral,
                                           card: card,
                                           actionContext: actionContext)
            .rx.request
            .map { _ in }
    }
    
    static func block(card: Fantasy.Card, actionContext: Fantasy.Card.ActionContext) -> Single<Void> {
        
        return Fantasy.Request.ReactOnCard(reaction: .block,
                                           card: card,
                                           actionContext: actionContext)
            .rx.request
            .map { _ in }
    }
    
    static func likedCards(of user: UserIdentifier) -> Single<[Fantasy.Request.LikedCards.SneakPeek]> {
        return Fantasy.Request.LikedCards(of: user).rx.request
    }
    
    static func card(by id: String) -> Single<Fantasy.Card> {
        return Fantasy.Request.FetchCard(id: id).rx.request
    }
    
    static func collection(by id: String) -> Single<Fantasy.Collection> {
        return Fantasy.Request.FetchCollection(id: id).rx.request
    }
 
}

extension Fantasy.Manager {
    
    static func fetchSwipesDeck(in room: Room) -> Single< AppState.FantasiesDeck > {
        
        return Fantasy.Request.FetchRoomCards(room: room).rx.request
        .map { x in
            AppState.FantasiesDeck(cards: x.cards,
                                   wouldUpdateAt: x.deckState.wouldBeUpdatedAt)
        }
        
        
    }
    
    static func like(card: Fantasy.Card, in room: RoomIdentifier,
                     actionContext: Fantasy.Card.ActionContext) -> Single<Fantasy.Request.ReactOnRoomCard.MutualIndicator> {
        
        Dispatcher.dispatch(action: LikeRoomCardLogic(card: card))
        
        return Fantasy.Request.ReactOnRoomCard(reaction: .like,
                                               card: card,
                                               room: room,
                                               actionContext: actionContext)
            .rx.request
    }
    
    static func dislike(card: Fantasy.Card, in room: RoomIdentifier,
                        actionContext: Fantasy.Card.ActionContext) -> Single<Fantasy.Request.ReactOnRoomCard.MutualIndicator> {
        
        return Fantasy.Request.ReactOnRoomCard(reaction: .dislike,
                                               card: card,
                                               room: room,
                                               actionContext: actionContext)
            .rx.request
            
    }
    
    static func mutualCards(in room: RoomIdentifier) -> Single<[Fantasy.Card]> {
        return Fantasy.Request.MutualRoomCards(room: room).rx.request
    }
    
}
