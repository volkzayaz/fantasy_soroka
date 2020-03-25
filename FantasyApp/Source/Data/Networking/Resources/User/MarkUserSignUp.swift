//
//  MarkUserSignUp.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 25.03.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct MarkUserSignUp: AuthorizedAPIResource {
    
    var path: String {
        return "/users/me/signup"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    typealias responseType = EmptyResponse
    
    var task: Task {
        return .requestPlain
    }
    
}



