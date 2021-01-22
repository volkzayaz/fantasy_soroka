//
//  UsersResource.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 06.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UsersResource: AuthorizedAPIResource {
    
    var path: String {
        return "users"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    typealias responseType = Response
    
    var task: Task {
        var parameters: [String : Any] = [
            "gender": discoveryFilter.filter.gender.rawValue,
            "ageFrom": discoveryFilter.filter.age.lowerBound,
            "ageTo": discoveryFilter.filter.age.upperBound,
            "isViewed": isViewed
        ]
        
        if let communityID = discoveryFilter.community?.objectId {
            parameters["community"] = communityID
        }
        
        if let isGlobalMode = discoveryFilter.filter.isGlobalMode {
            parameters["globalModeSearch"] = isGlobalMode && isSubscribed
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding(destination: .queryString, boolEncoding: .literal))
    }
    
    let discoveryFilter: DiscoveryFilter
    let isSubscribed: Bool
    let isViewed: Bool
    
    struct Response: Decodable {
        
        let page: Int
        let pageSize: Int
        let users: [UserProfile]
    }
}
