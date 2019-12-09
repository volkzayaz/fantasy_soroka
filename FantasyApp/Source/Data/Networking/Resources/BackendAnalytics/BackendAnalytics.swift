//
//  BackendAnalytics.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 07.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct ConsiderPurchase: AuthorizedAPIResource, AnalyticsNetworkRequest {
    
    enum Good: String {
        case collection, subscription
    }; let of: Good
    
    var path: String {
        return "/analytics/track/considered-purchases/\(of.rawValue)"
    }
    
    var method: Moya.Method {
        return .put
    }
        
    typealias responseType = EmptyResponse
    
    var task: Task {
        return .requestPlain
    }
    
}
