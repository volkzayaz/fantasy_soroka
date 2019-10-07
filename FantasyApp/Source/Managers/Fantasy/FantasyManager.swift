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
    static func fetchSwipeState() -> Single< AppState.SwipeState.Restriction > {
        
        return Fantasy.Request.SwipeState().rx.request
            .map { res in
                
                if res.amount > 0 {
                    return .swipeCount(res.amount)
                }
                
                if let x = res.wouldBeUpdatedAt {
                    return .waiting(till: x)
                }
                
                fatalErrorInDebug("Server returned neither update date, nor available amount")
                return .waiting(till: Date(timeIntervalSinceNow: 24 * 3600))
            }
        
    }
    
    static func fetchMainCards(localLimit: Int) -> Single< [Fantasy.Card] > {
        
        return Fantasy.Request.Deck().rx.request
            .map { Array($0.prefix(upTo: localLimit)) }
                
    }
    
    static func searchFor(query: String) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")

        fatalErrorInDebug("Not implemented so far")
        
        return .just([])

    }
    
    static func fetchCollections() -> Single< [Fantasy.Collection] > {
        return Fantasy.Request.Collection().rx.request
    }
 
    static func like(card: Fantasy.Card) -> Single<Void> {
        return .just( () )
    }
    
    static func dislike(card: Fantasy.Card) -> Single<Void> {
        return .just( () )
    }
    
    static func neutral(card: Fantasy.Card) -> Single<Void> {
        return .just( () )
    }
    
}
