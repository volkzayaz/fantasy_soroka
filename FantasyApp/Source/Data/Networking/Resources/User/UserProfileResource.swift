//
//  UserProfileResource.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 17.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UserProfileResource: AuthorizedAPIResource {
    
    var path: String {
        return "users/\(id)"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    typealias responseType = UserProfile
    
    var task: Task {
        .requestPlain
    }
    
    let id: String
}
