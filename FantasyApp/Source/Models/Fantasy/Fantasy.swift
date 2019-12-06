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
        
        enum CodingKeys: String, CodingKey {
            case id
            case text
            case story
            case imageURL = "src"
            case isPaid
            case likes
            case dislikes
            case blocks
            case category = "type"
//            case collectionName
//            case art
        }
        
        let id: String
        let text: String
        let story: String
        let imageURL: String
        let isPaid: Bool
        let likes: Int
        let dislikes: Int
        let blocks: Int
        let category: String
//        let collectionName: String
//        let art: String
        
        ///surrogate property
        ///whether this card belongs to free collection or payed collection
        var isFree: Bool {
            return !isPaid
        }
        
        var identity: String {
            return id
        }
        
        enum Reaction: Int, Codable {
               case like, dislike, block, neutral
        };
    }
    
    struct Collection: Equatable, IdentifiableType, Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case details
            case whatsInside
            case imageURL = "src"
            case cardsCount = "size"
            case isPurchased
            case productId
        }
        
        let id: String
        let title: String
        let details: String
        let whatsInside: String
        let imageURL: String
        let cardsCount: Int
        let isPurchased: Bool
        let productId: String? ///absence of ProductID means product is free
        
        var identity: String {
            return id
        }
    }
    
}

struct ProtectedEntity<T: IdentifiableType & Equatable>: IdentifiableType, Equatable {
    let entity: T
    let isProtected: Bool

    var identity: T.Identity {
        return entity.identity
    }
    
}

extension AppState.FantasiesDeck {

    /*
        returns - Bool.
            False - state should be refreshed from server
            True  - state is consistent with server
     */
    mutating func pop(card: Fantasy.Card) -> Bool {
        
        guard case .cards(var x) = self, x.count > 0 else {
            return true
        }
        
        guard let maybeIndex = x.firstIndex(of: card) else {
            return false
        }
        
        x.remove(at: maybeIndex)
        
        guard x.count > 0 else {
            self = .empty(till: Date(timeIntervalSinceNow: 3600 * 24))
            return true
        }
        
        self = .cards(x)
        return true
        
    }
    
}

extension Fantasy.Card {
    
//    static var fakes: [Fantasy.Card] {
//
//        return [.init(name: "BJ", description: "Some vanila stuff", isPaid: false),
//                .init(name: "Go down", description: "Even more vanila stuff", isPaid: false),
//                .init(name: "anal", description: "Doing kinky dirty stuff", isPaid: false),
//                .init(name: "BDSM", description: "For those who love it rough", isPaid: false),
//                .init(name: "ESPN", description: "Watch your team getting fucked every weekend online. Real hardcore shit", isPaid: false)]
//
//    }
    
}

extension Fantasy.Collection {
    
//    static var fakes: [Fantasy.Collection] {
//        
//        let x = Fantasy.Collection(name: "Vanila",
//                                   cards: [.init(name: "Kiss on chick", description: "Some vanila stuff", isPaid: true),
//                                           .init(name: "Kiss on lips", description: "Even more vanila stuff", isPaid: true),
//                                           .init(name: "Kiss on neck", description: "neck stuff", isPaid: true)])
//        
//        let y = Fantasy.Collection(name: "Public",
//                                   cards: [.init(name: "Fuck inside a bus", description: "lorem ipsum bus", isPaid: true),
//                                           .init(name: "Fuck in the park", description: "lorem ipsum park", isPaid: true),
//                                           .init(name: "Fuck in dressing room", description: "lorem ipsum dressing", isPaid: true)])
//        
//        let z = Fantasy.Collection(name: "Gangbang",
//                                   cards: [.init(name: "Fuck 3 guys at a time", description: "lorem ipsum", isPaid: true),
//                                           .init(name: "Fuck 7 guys at a time", description: "lorem ipsum 7", isPaid: true),
//                                           .init(name: "Fuck the whole football team", description: "lorem ipsum 11", isPaid: true)])
//        
//        return [x, y ,z]
//        
//    }
    
}
