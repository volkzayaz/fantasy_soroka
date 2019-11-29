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
                
                if response.cards.count > 0 {
                    return .cards(response.cards)
                }
                
                if let x = response.deckState.wouldBeUpdatedAt {
                    return .empty(till: x)
                }
                
                fatalErrorInDebug("Server returned neither update date, nor available amount")
                return .empty(till: Date(timeIntervalSinceNow: 24 * 3600))
            }
        
    }
    
    static func searchFor(query: String) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")

        fatalErrorInDebug("Not implemented for release 1")
        
        return .just([])

    }
    
    static func fetchCollections() -> Single< [Fantasy.Collection] > {
        return Fantasy.Request.Collection().rx.request
            .map { $0.filter { $0.productId != nil } }
    }
    
    static func fetchCollectionsCards(collection: Fantasy.Collection) -> Single< [Fantasy.Card] > {
        return Fantasy.Request.CollectionCards(collection: collection).rx.request
            .map { $0.availableCards }
    }
 
    static func like(card: Fantasy.Card) -> Single<Void> {
        return Fantasy.Request.ReactOnCard(reaction: .like,
                                           card: card)
            .rx.request
            .map { _ in }
    }
    
    static func dislike(card: Fantasy.Card) -> Single<Void> {
        return Fantasy.Request.ReactOnCard(reaction: .dislike,
                                           card: card)
            .rx.request
            .map { _ in }
    }
    
    static func neutral(card: Fantasy.Card) -> Single<Void> {
        return Fantasy.Request.ReactOnCard(reaction: .neutral,
                                           card: card)
            .rx.request
            .map { _ in }
    }
    
    static func likedCards(of user: User) -> Single<[Fantasy.Request.LikedCards.SneakPeek]> {
        return Fantasy.Request.LikedCards(of: user).rx.request
    }
 
}

extension Fantasy.Manager {
    
    static func fetchSwipesDeck(in room: Room) -> Single< Fantasy.Request.FetchRoomCards.Response > {
        
        return Fantasy.Request.FetchRoomCards(room: room).rx.request
        
    }
    
    static func like(card: Fantasy.Card, in room: Room) -> Single<Fantasy.Request.ReactOnRoomCard.MutualIndicator> {
        return Fantasy.Request.ReactOnRoomCard(reaction: .like,
                                               card: card,
                                               room: room)
            .rx.request
    }
    
    static func dislike(card: Fantasy.Card, in room: Room) -> Single<Fantasy.Request.ReactOnRoomCard.MutualIndicator> {
        return Fantasy.Request.ReactOnRoomCard(reaction: .dislike,
                                               card: card,
                                               room: room)
            .rx.request
            
    }
    
    static func mutualCards(in room: RoomIdentifier) -> Single<[Fantasy.Card]> {
        return Fantasy.Request.MutualRoomCards(room: room).rx.request
    }
    
}
