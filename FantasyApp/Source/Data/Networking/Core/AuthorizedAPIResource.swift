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
        return ["Content-Type": "application/json",
                "authorization": "r:6b1e0f9d6554574bbd920614a8f2811c"]
    }
}

