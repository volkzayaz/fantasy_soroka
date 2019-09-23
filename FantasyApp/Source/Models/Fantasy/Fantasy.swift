//
//  Fantasy.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources

enum Fantasy {}
extension Fantasy {
    
    struct Card: Equatable, IdentifiableType, Codable {
        let name: String
        let description: String
        
        ///surrogate property
        ///whether this card belongs to free collection or payed collection
        let isFree: Bool
        
        var identity: String {
            return name
        }
    }
    
    struct Collection: Equatable, IdentifiableType, Codable {
        let name: String
        let cards: [Card]
        
        var identity: String {
            return name
        }
    }
    
}

extension AppState.SwipeState.Restriction {
    
    mutating func decremet() {
        
        guard case .swipeCount(let x) = self, x > 0 else {
            return
        }
        
        if x == 1 {
            self = .waiting(till: Date(timeIntervalSinceNow: 3600 * 24))
            return
        }
        
        self = .swipeCount(x - 1)
        
    }
    
}

extension Fantasy.Card {
    
    static var fakes: [Fantasy.Card] {
        
        return [.init(name: "BJ", description: "Some vanila stuff", isFree: true),
                .init(name: "Go down", description: "Even more vanila stuff", isFree: true),
                .init(name: "anal", description: "Doing kinky dirty stuff", isFree: true),
                .init(name: "BDSM", description: "For those who love it rough", isFree: true),
                .init(name: "ESPN", description: "Watch your team getting fucked every weekend online. Real hardcore shit", isFree: true)]
        
    }
    
}

extension Fantasy.Collection {
    
    static var fakes: [Fantasy.Collection] {
        
        let x = Fantasy.Collection(name: "Vanila",
                                   cards: [.init(name: "Kiss on chick", description: "Some vanila stuff", isFree: false),
                                           .init(name: "Kiss on lips", description: "Even more vanila stuff", isFree: false),
                                           .init(name: "Kiss on neck", description: "neck stuff", isFree: false)])
        
        let y = Fantasy.Collection(name: "Public",
                                   cards: [.init(name: "Fuck inside a bus", description: "lorem ipsum bus", isFree: false),
                                           .init(name: "Fuck in the park", description: "lorem ipsum park", isFree: false),
                                           .init(name: "Fuck in dressing room", description: "lorem ipsum dressing", isFree: false)])
        
        let z = Fantasy.Collection(name: "Gangbang",
                                   cards: [.init(name: "Fuck 3 guys at a time", description: "lorem ipsum", isFree: false),
                                           .init(name: "Fuck 7 guys at a time", description: "lorem ipsum 7", isFree: false),
                                           .init(name: "Fuck the whole football team", description: "lorem ipsum 11", isFree: false)])
        
        return [x, y ,z]
        
    }
    
}
