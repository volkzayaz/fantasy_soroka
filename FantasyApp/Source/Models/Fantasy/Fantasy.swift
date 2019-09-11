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
    
    struct Card: Equatable, IdentifiableType {
        let name: String
        let description: String
        
        var identity: String {
            return name
        }
    }
    
    struct Collection: Equatable {
        let cards: [Card]
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
        
        return [.init(name: "BJ", description: "Some vanila stuff"),
                .init(name: "Go down", description: "Even more vanila stuff"),
                .init(name: "anal", description: "Doing kinky dirty stuff"),
                .init(name: "BDSM", description: "For those who love it rough"),
                .init(name: "ESPN", description: "Watch your team getting fucked every weekend online. Real hardcore shit")]
        
    }
    
}
