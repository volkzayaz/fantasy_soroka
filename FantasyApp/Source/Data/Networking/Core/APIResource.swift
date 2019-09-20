//
//  APIResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public protocol APIResource: TargetType, ReactiveCompatible {
    
    associatedtype responseType: Decodable
}

extension APIResource {
    // TODO: Env properties in .json config or plist?
    var baseURL: URL {
        return URL(string: "https://apidev.fantasyapp.com/api")!
    }

    var sampleData: Data {
        return Data()
    }

    var validationType: ValidationType {
        return .successCodes
    }

    // TODO: Default headers in .json config?
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
