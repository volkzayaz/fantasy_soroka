//
//  ConectionResource.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

fileprivate enum ConnectionStatus: String, Codable {
    case invited
    case rejected
    case connected
}

struct ConnectionResponse: Codable {
    
    let userId: String
    let targetUserId: String
    let connectTypes: [ConnectionRequestType]
    fileprivate let status: ConnectionStatus
    let responseConnectType: String?
    
    var toNative: Connection {
        
        guard let connectType = connectTypes.first,
            let currentUser = User.current?.id else {
                fatalErrorInDebug("Can't determine connect type, or currentUser is not defined")
                return .absent
        }
        
        if case .rejected = status {
            return .rejected
        }
        
        if case .connected = status {
            return .mutual
        }
        
        if targetUserId == currentUser {
            return .incomming(request: connectType)
        } else if userId == currentUser {
            return .outgoing(request: connectType)
        }
        else {
            fatalErrorInDebug("currentUser is not part of this connection \(self)")
            return .absent
        }
        
    }
}

///Find out how you are connected with other user (Connection)
struct GetConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    typealias responseType = ConnectionResponse?
    
    let with: User
}

///If you're not mutual with user you can get his attention by creating/updating your request outgoing (ConnectionRequestType)
struct UpsertConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    typealias responseType = ConnectionResponse
    
    var task: Task {
        return .requestParameters(parameters: ["connectionType": type.rawValue],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    let type: ConnectionRequestType
}

struct AcceptConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)/response"
    }
    
    var method: Moya.Method {
        return .post
    }

    typealias responseType = ConnectionResponse
    
    var task: Task {
        return .requestParameters(parameters: ["status": ConnectionStatus.connected.rawValue,
                                               "responseConnectType": type.rawValue ],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    let type: ConnectionRequestType
}

struct RejectConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)/response"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    typealias responseType = ConnectionResponse
    
    var task: Task {
        return .requestParameters(parameters: ["status": ConnectionStatus.rejected.rawValue],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    
}

struct DeleteConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)"
    }
    
    var method: Moya.Method {
        return .delete
    }
    
    ///TODO: this should really be just Void
    struct Empty: Codable {}
    typealias responseType = Empty
    
    var task: Task {
        return .requestPlain
    }
    
    let with: User
    
}

struct GetConnectionRequests: AuthorizedAPIResource {
    
    var path: String {
        return "/users/me/connections/requests"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    struct Response: Codable {
        let userId: String
        let status: ConnectionRequestType
    }
    
    typealias responseType = [Response]
    
    var task: Task {
        return .requestPlain
    }
    
}
