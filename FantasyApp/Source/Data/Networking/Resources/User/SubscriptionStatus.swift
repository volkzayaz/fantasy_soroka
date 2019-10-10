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
    
    struct SendReceipt: AuthorizedAPIResource {
        
        let recieptData: Data
        
        var path: String {
            return "users/me/subscription"
        }
        
        var method: Moya.Method {
            return .post
        }
        
        typealias responseType = User.Subscription
        
        var task: Task {
            return .requestParameters(parameters:
                [
                    "appType": "ios",
                    "receipt": recieptData.base64EncodedString()
                ],
                                      encoding: JSONEncoding.default)
        }
        
    }
    
    struct PurchaseCollection: AuthorizedAPIResource {
        
        let collection: Fantasy.Collection
        let recieptData: Data
        
        var path: String {
            return "/fantasy-collections/\(collection.id)/purchase"
        }
        
        var method: Moya.Method {
            return .post
        }
        
        typealias responseType = EmptyResponse
        
        var task: Task {
            return .requestParameters(parameters:
                [
                    "appType": "ios",
                    "receipt": recieptData.base64EncodedString()
                ],
                                      encoding: JSONEncoding.default)
        }
        
    }
    
}
