//
//  Subscription.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/8/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

extension User {
    enum Request {}
}

extension User.Request {
    
    struct SubscriptionStatus: AuthorizedAPIResource {
        
        var path: String {
            return "users/me/subscription"
        }
        
        var method: Moya.Method {
            return .get
        }
        
        typealias responseType = User.Subscription
        
        var task: Task {
            return .requestPlain
        }
        
    }
    
}
