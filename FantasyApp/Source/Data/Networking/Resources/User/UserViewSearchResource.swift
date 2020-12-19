//
//  UserViewSearchResource.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 08.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UserViewSearchResource: AuthorizedAPIResource {
    
    var path: String {
        return "users/\(user.id)/view-search"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    typealias responseType = EmptyResponse
    
    var task: Task {
        .requestPlain
    }
    
    let user: UserIdentifier
}
