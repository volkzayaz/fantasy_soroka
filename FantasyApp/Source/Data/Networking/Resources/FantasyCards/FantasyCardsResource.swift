//
//  FantasyCardsResource.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct FantasySwipeState: AuthorizedAPIResource {
    
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
