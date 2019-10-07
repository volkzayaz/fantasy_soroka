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
        
        ///TODO: this mapping is bad
        typealias responseType = [Fantasy.Collection]
        
        var method: Moya.Method {
            return .get
        }
        
        var path: String {
            return "/fantasy-collections"
        }
        
        var task: Task {
            return .requestPlain
        }
        
    }
    
    
    
}


