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
        
        //fatalError("Implement me")
        return .just( .swipeCount(5) )
        
        
        //return .just( .waiting(till: Date(timeIntervalSinceNow: 1234)) )
    }
    
    static func fetchMainCards(localLimit: Int) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")
        
        return .just( Array(Fantasy.Card.fakes.prefix(localLimit)) )
        
    }
    
    static func searchFor(query: String) -> Single< [Fantasy.Card] > {
        
        //fatalError("Implement me")
        
        let allCards = Fantasy.Card.fakes
        
        guard query.count > 0 else {
            return .just(allCards)
        }
        
        return .just( allCards.filter { $0.name.lowercased().contains(query.lowercased()) } )
        
    }
    
}
