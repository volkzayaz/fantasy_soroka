//
//  AuthorizedAPIResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 10.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation

public protocol AuthorizedAPIResource: APIResource {

}

extension AuthorizedAPIResource {
    var headers: [String : String]? {
        
        guard let token = PFUser.current()?.sessionToken else {
            fatalErrorInDebug("No sessionToken available. Can't access authorized resource \(self)")
            return [:]
        }
        
        return ["Content-Type": "application/json",
                "authorization": token]
    }
}

