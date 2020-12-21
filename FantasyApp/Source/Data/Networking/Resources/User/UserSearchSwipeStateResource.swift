//
//  UserSearchSwipeStateResource.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 06.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UserSearchSwipeStateResource: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/user-search-swipe-state"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    typealias responseType = SearchSwipeState
    
    var task: Task {
        .requestPlain
    }
}
