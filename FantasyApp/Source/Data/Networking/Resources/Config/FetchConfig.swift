//
//  FetchConfig.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 29.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct ServerConfig: Codable {
    
    let IAPSubscriptionProductId: String
    let minSupportedIOSVersion: String
    
}

struct FetchConfig: AuthorizedAPIResource {
    
    var path: String {
        return "/global-settings"
    }
    
    var method: Moya.Method {
        return .get
    }
        
    typealias responseType = ServerConfig
    
    var task: Task {
        return .requestPlain
    }
    
}
