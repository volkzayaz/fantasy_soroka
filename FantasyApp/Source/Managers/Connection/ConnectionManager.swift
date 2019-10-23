//
//  ConnectionManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum ConnectionManager {}
extension ConnectionManager {
    
    static func relationStatus(with user: User) -> Single<Connection> {
        return GetConnection(with: user).rx.request
            .map { $0?.toNative ?? .absent }
    }
    
    static func initiate(with user: User, type: ConnectionRequestType) -> Single<Connection> {
        
        PushManager.sendPush(to: user, text: "\(User.current!.bio.name) is interested in you")
        
        return UpsertConnection(with: user, type: type)
            .rx.request.map { $0.toNative }
    }
    
    static func likeBack(user: User) -> Single<Connection> {
        
        PushManager.sendPush(to: user, text: "\(User.current!.bio.name) accepted your room request")
        
        return AcceptConnection(with: user, type: .like)
            .rx.request.map { $0.connection.toNative }
    }
    
    static func reject(user: User) -> Single<Connection> {
        return RejectConnection(with: user)
            .rx.request.map { $0.connection.toNative }
    }
    
    static func deleteConnection(with: User) -> Single<Void> {
        return DeleteConnection(with: with)
            .rx.request.map { _ in }
    }
    
    static func connectionRequests(source: GetConnectionRequests.Source) -> Single<[ConnectedUser]> {
        
        return GetConnectionRequests(source: source).rx.request
            .flatMap { r in
                
                return User.query
                    .whereKey("objectId", containedIn: r.map { $0.otherUserId })
                    .rx.fetchAllObjects()
                    .map { ($0, r) }
            }
            .map { (users, requests) in
                
                let connections = Dictionary(uniqueKeysWithValues: requests.map { ($0.otherUserId, $0.connection) })
                
                return users.compactMap { pfUser in
                    
                    guard let user = try? User(pfUser: pfUser as! PFUser),
                        let connection = connections[user.id]?.toNative else {
                        return nil
                    }
                    
                    let room: Chat.RoomRef
                    let connectType: Set<ConnectionRequestType>
                    switch connection {
                    case .incomming(let request, let draftRoom):
                        connectType = request
                        room = draftRoom
                        
                    case .outgoing(let request, let draftRoom):
                        connectType = request
                        room = draftRoom
                       
                    default:
                        return nil
                        
                    }
                    
                    return ConnectedUser(user: user,
                                         room: room,
                                         connectTypes: connectType)
                }
                 
            }
    }

}
