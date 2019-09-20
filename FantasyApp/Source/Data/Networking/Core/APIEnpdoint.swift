//
//  APIEnpdoint.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya

public enum APIEnpdoint {
    case updateAvatar
    
    case fantasySwipeState
    
    

    private enum Path: String {
        case users
        case me
        case avatar
    }

    private enum PathComponent {
        case path(Path)
        case value(String)
    }

    private var components: [PathComponent] {
        switch self {
        case .updateAvatar:
            return [.path(.users), .path(.me), .path(.avatar)]
        case .fantasySwipeState:
            return [.value("users/me/swipe-state")]
        }
    }
}

extension APIEnpdoint {
    public var path: String {
        let stringRepresentations = components.map { (component: PathComponent) -> String in
            switch component {
            case .path(let path): return "/\(path.rawValue)"
            case .value(let value): return "/\(value)"
            }
        }
        return stringRepresentations.joined(separator: "")
    }

    public var method: Moya.Method {
        switch self {
        case .updateAvatar:
            return .put
        case .fantasySwipeState:
            return .get
        }
    }
}

