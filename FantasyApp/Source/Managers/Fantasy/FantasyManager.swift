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
        
//        FantasySwipeState().rx.request
//            .subscribe(onSuccess: { (res) in
//                print(res)
//            }) { (error) in
//                print(error)
//        }
        
        //fatalError("Implement me")
        return .just( .swipeCount(5) )
    }
    
    static func fetchMainCards(localLimit: Int) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")
        
        let freeCards = Array(Fantasy.Card.fakes.prefix(localLimit))
        
        let payedCards = appStateSlice.currentUser?.fantasies.purchasedCollections.flatMap { $0.cards } ?? []
        
        return .just( (freeCards + payedCards).shuffled() )        
    }
    
    static func searchFor(query: String) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")
        
        let allCards = Fantasy.Card.fakes
        
        guard query.count > 0 else {
            return .just(allCards)
        }
        
        return .just( allCards.filter { $0.name.lowercased().contains(query.lowercased()) } )
        
    }
    
    static func fetchCollections() -> Single< [Fantasy.Collection] > {
        
        //fatalError("Implement me")
        
        return .just( Fantasy.Collection.fakes )
        
    }
    
}