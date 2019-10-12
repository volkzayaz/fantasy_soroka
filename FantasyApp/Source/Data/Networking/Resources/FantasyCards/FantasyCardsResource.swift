//
//  FantasyCardsResource.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

extension Fantasy {
    enum Request {}
}

extension Fantasy.Request {
    
    struct SwipeState: AuthorizedAPIResource {
        
        struct Response: Codable {
            let amount: Int
            let wouldBeUpdatedAt: Date?
        }
        
        typealias responseType = Response
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "users/me/swipe-state"
        }
        
        var task: Task {
            return .requestPlain
        }
        
    }
    
    struct Deck: AuthorizedAPIResource {
        
        typealias responseType = [Fantasy.Card]
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "/fantasy-cards/deck"
        }
        
        var task: Task {
            return .requestPlain
        }
        
    }
    
    struct Collection: AuthorizedAPIResource {
        
        typealias responseType = [Fantasy.Collection]
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "/fantasy-collections"
        }
        
        var task: Task {
            return .requestParameters(parameters: ["isPaid" : true], encoding: URLEncoding.default)
        }
        
    }
    
    struct FetchCards: AuthorizedAPIResource {
        
        enum ReactionType {
            case liked, disliked, blocked
        }; let reactionType: ReactionType
     
        typealias responseType = [Fantasy.Card]
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "/fantasy-cards"
        }
        
        var task: Task {
            
            var params: [String: Bool] = [:]
            switch reactionType {
            case .liked:    params["liked"] = true
            case .disliked: params["disliked"] = true
            case .blocked:  params["blocked"] = true
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
        
    }
 
    struct ReactOnCard: AuthorizedAPIResource {
        
        let reaction: Fantasy.Card.Reaction
        let card: Fantasy.Card
        
        typealias responseType = EmptyResponse
        
        var method: Moya.Method {
            return .put
        }
        
        var path: String {
            switch reaction {
            case .like   : return "/fantasy-cards/\(card.id)/like"
            case .dislike: return "/fantasy-cards/\(card.id)/dislike"
            case .neutral: return "/fantasy-cards/\(card.id)/neutral"
            case .block  : return "/fantasy-cards/\(card.id)/block"
            }
            
        }
        
        var task: Task {
            return .requestPlain
        }
        
    }

    struct MutualCards: AuthorizedAPIResource {
        
        let with: User
        
        struct SurrogateCollection: Codable {
            let description: String
            let src: String
            let cards: [Fantasy.Card]
        }; typealias responseType = [SurrogateCollection]
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "/users/\(with.id)/fantasy-collections"
        }
        
        var task: Task {
            return .requestPlain
        }
        
    }
    
}


