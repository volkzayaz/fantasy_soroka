//
//  FantasyCardsResource.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct FantasySwipeState: AuthorizedAPIResource {
    
    struct Response: Codable {
        let amount: Int
        let wouldBeUpdatedAt: Date?
    }
    
    var endpoint: APIEnpdoint {
        return .fantasySwipeState
    }
    
    typealias responseType = Response
    
}
