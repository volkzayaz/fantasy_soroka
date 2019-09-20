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

///Find out how you are connected with other user (Connection)
struct GetConnection: AuthorizedAPIResource {
    
    var path: String {
        return "users/me/connections/\(with.id)"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    struct Response: Codable {
        
        let userId: String
        let targetUserId: String
        let connectType: String
        fileprivate let status: ConnectionStatus
        let responseConnectType: String?

        var toNative: Connection {

            return .absent

        }
    }
    
    var task: Task {
        return .requestPlain
    }
    
    typealias responseType = Response
    
    let with: User
}

///If you're not mutual with user you can get his attention by creating/updating your request outgoing (ConnectionRequestType)
struct UpsertConnection: AuthorizedAPIResource {
    
    var path: String {
        return "​​users​/me/connections​/\(with.id)"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    struct Response: Codable {
        
        let userId: String
        let targetUserId: String
        let connectType: String
        let status: ConnectionRequestType
        let responseConnectType: String?
        //
        //        var toNative: Connection {
        //
        //
        //
        //        }
    }
    
    typealias responseType = Response?
    
    var task: Task {
        return .requestParameters(parameters: ["connectionType": type.rawValue],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    let type: ConnectionRequestType
}

struct AcceptConnection: AuthorizedAPIResource {
    
    var path: String {
        return "​​users​/me​/connections​/\(with.id)/response"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    struct Response: Codable {
        
        let userId: String
        let targetUserId: String
        let connectType: String
        let status: ConnectionRequestType
        let responseConnectType: String?
        //
        //        var toNative: Connection {
        //
        //
        //
        //        }
    }
    
    typealias responseType = Response?
    
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
        return "​​users​/me​/connections​/\(with.id)/response"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    struct Response: Codable {
        
        let userId: String
        let targetUserId: String
        let connectType: String
        let status: ConnectionRequestType
        let responseConnectType: String?
        //
        //        var toNative: Connection {
        //
        //
        //
        //        }
    }
    
    typealias responseType = Response?
    
    var task: Task {
        return .requestParameters(parameters: ["status": ConnectionStatus.rejected.rawValue],
                                  encoding: JSONEncoding())
    }
    
    let with: User
    
}
