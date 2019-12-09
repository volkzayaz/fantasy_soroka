//
//  ConnectionManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

protocol UserIdentifier {
    var id: String { get }
}

extension User: UserIdentifier {}
extension String: UserIdentifier {
    var id: String { return self }
}

enum ConnectionManager {}
extension ConnectionManager {
    
    static func relationStatus(with user: User) -> Single<Connection> {
        return GetConnection(with: user).rx.request
            .map { $0?.toNative ?? .absent }
    }
    
    ///does not take into account whether self sent requests or other party sent requests
    static func requestTypes(with user: UserIdentifier) -> Single<Set<ConnectionRequestType>> {
        return GetConnection(with: user).rx.request
            .map { $0?.connectTypes ?? [] }
    }
    
    static func initiate(with user: UserIdentifier, type: ConnectionRequestType) -> Single<Connection> {
        return UpsertConnection(with: user, type: type)
            .rx.request.map { $0.toNative }
        
    }
    
    static func likeBack(user: UserIdentifier, context: Analytics.Event.RoomAccepted.Source) -> Single<Connection> {
        
        print("Analytics: backend Request = Accept Connection source: \(context.rawValue)")
        
        return AcceptConnection(with: user, type: .like, navigationContext: context)
            .rx.request.map { $0.connection.toNative }
            .do(onSuccess: { (_) in
                ///complex freeze logic requires recalculating all rooms
                Dispatcher.dispatch(action: TriggerRoomsRefresh())
            })
    }
    
    static func reject(user: UserIdentifier) -> Single<Connection> {
        return RejectConnection(with: user)
            .rx.request.map { $0.connection.toNative }
            .do(onSuccess: { (_) in
                ///complex freeze logic requires recalculating all rooms
                Dispatcher.dispatch(action: TriggerRoomsRefresh())
            })
    }
    
    static func deleteConnection(with: User) -> Single<Void> {
        return DeleteConnection(with: with)
            .rx.request.map { _ in }
            .do(onSuccess: { (_) in
                ///complex freeze logic requires recalculating all rooms
                Dispatcher.dispatch(action: TriggerRoomsRefresh())
            })
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
                    
                    let room: RoomRef
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
                                         connectTypes: connectType,
                                         source: source)
                }
                 
            }
    }

}
