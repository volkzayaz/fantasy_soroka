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
    let connectTypes: Set<ConnectionRequestType>
    fileprivate let status: ConnectionStatus
    let responseConnectType: String?
    let roomId: String? ///always exists unless rejected
    
    var toNative: Connection {
        
        var room: RoomRef {
            guard let id = roomId else {
                fatalError("Connection does not have assosiated roomId. Details: \(self)")
            }
            
            return RoomRef(id: id)
        }
        
        guard connectTypes.count > 0,
            let currentUser = User.current?.id else {
                fatalErrorInDebug("Can't determine connect type, or currentUser is not defined")
                return .absent
        }
        
        guard targetUserId == currentUser ||
            userId == currentUser else {
                fatalErrorInDebug("currentUser is not part of this connection \(self)")
                return .absent
        }
        
        if case .rejected = status {
            
            return targetUserId == currentUser ?
                .iRejected :
                .iWasRejected
            
        }
        
        if case .connected = status {
            return .mutual(room: room)
        }
        
        if targetUserId == currentUser {
            return .incomming(request: connectTypes, draftRoom: room)
        } else if userId == currentUser {
            return .outgoing(request: connectTypes, draftRoom: room)
        }
        else {
            return .absent
        }
        
    }
    
    var otherUserId: String {
        if userId == User.current?.id {
            return targetUserId
        }
        else if targetUserId == User.current?.id {
            return userId
        }
        
        fatalErrorInDebug("currentUser is not part of this connection \(self)")
        return ""
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

    typealias responseType = AcceptConnectionResponse
    
    var task: Task {
        return .requestParameters(parameters: ["status": ConnectionStatus.connected.rawValue,
                                               "responseConnectType": type.rawValue ],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    let type: ConnectionRequestType
 
    struct AcceptConnectionResponse: Codable {
        let connection: ConnectionResponse
        let room: Room
    }
    
}

struct RejectConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)/response"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    typealias responseType = RejectConnectionResponse
    
    var task: Task {
        return .requestParameters(parameters: ["status": ConnectionStatus.rejected.rawValue],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    
    struct RejectConnectionResponse: Codable {
        let connection: ConnectionResponse
    }
}

struct DeleteConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)"
    }
    
    var method: Moya.Method {
        return .delete
    }
    
    typealias responseType = EmptyResponse
    
    var task: Task {
        return .requestPlain
    }
    
    let with: User
    
}

struct GetConnectionRequests: AuthorizedAPIResource {
    
    enum Source { case incomming, outgoing }
    
    var path: String {
        
        switch source {
        case .incomming:
            return "/users/me/connections/requests/incoming"
            
        case .outgoing:
            return "/users/me/connections/requests/outgoing"
            
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    struct Response: Codable {
        let connection: ConnectionResponse
        
        var otherUserId: String {
            
            if User.current!.id == connection.targetUserId {
                return connection.userId
            }
            
            return connection.targetUserId
        }
        
    }
    
    typealias responseType = [Response]
    
    var task: Task {
        return .requestPlain
    }
    
    let source: Source
    
}

struct GetAllConnections: AuthorizedAPIResource {
    
    var path: String {
        return "/users/me/connections"
    }
    
    var method: Moya.Method {
        return .get
    }
        
    typealias responseType = [ConnectionResponse]
    
    var task: Task {
        return .requestPlain
    }
    
}
