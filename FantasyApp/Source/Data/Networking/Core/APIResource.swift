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

public protocol APIResource: TargetType, Encodable, ReactiveCompatible {
    var endpoint: APIEnpdoint { get }

    associatedtype responseType: Decodable
}

extension APIResource {
    // TODO: Env properties in .json config or plist?
    var baseURL: URL {
        return URL(string: "https://apistg.fantasyapp.com/api")!
    }

    var path: String {
        return endpoint.path
    }

    var method: Moya.Method {
        return endpoint.method
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        return .requestJSONEncodable(self)
    }

    var validationType: ValidationType {
        return .successCodes
    }

    // TODO: Default headers in .json config?
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
