//
//  DeleteUser.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/13/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct DeleteUser: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/"
    }
    
    var method: Moya.Method {
        return .delete
    }
    
    typealias responseType = EmptyResponse
    
    var task: Task {
        return .requestPlain
    }
    
}
