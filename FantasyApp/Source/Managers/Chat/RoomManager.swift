//
//  RoomManager.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Parse
import ParseLiveQuery

enum RoomManager {}

extension RoomManager {
    
    static func sendMessage(_ message: Room.Message, to room: Room) -> Single<Void> {
        
        if let id = room.peer.userId {
            PushManager.sendPush(to: id,
                                 text: "\(User.current!.bio.name) sent you a message" )
        }
        
        return message.rxCreate().map { _ in }
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Single<[Room.Message]> {
        let query = Room.Message.query
                        .whereKey("roomId", equalTo: roomId)
                        .addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = limit

        return query.rx.fetchAll()
    }

    static func getAllRooms() -> Single<[Room]> {
        return RoomsResource().rx.request
    }

    static func getRoom(id: String) -> Single<Room> {
        
        if let room = appStateSlice.rooms.first(where: { $0.id == id }) {
            return .just(room)
        }
        
        return RoomResource(id: id).rx.request
    }

    // MARK: - Room creation
    static func createDraftRoom() -> Single<Room> {
        
        let settings = Room.Settings(isClosedRoom: true,
                                     isHideCommonFantasies: false,
                                     isScreenShieldEnabled: User.current?.subscription.isSubscribed ?? false,
                                     sharedCollections: [],
                                     notifications: .init(newMessage: true,
                                                          newFantasyMatch: true)
                                     )
        
        return CreateDraftRoomResource(settings: settings).rx.request
            .flatMap { room in
                return inviteUser(nil, to: room.id)
            }
            
    }

    static func inviteUser(_ userId: String?, to roomId: String) -> Single<Room> {
        return InviteParticipantResource(roomId: roomId, userId: userId).rx.request
    }

    static func assosiateSelfWith(roomRef: RoomRef, password: String) -> Single<Room> {
        return RoomStatusResource(roomRef: roomRef, password: password, status: .invited).rx.request
    }
    
    static func deleteRoom(_ roomId: String) -> Single<Void> {
        return DeleteRoomResource(roomId: roomId).rx.request.map { _ in }
    }
    
    // MARK: - Settings
    static func updateRoomSettings(roomId: String, settings: Room.Settings) -> Single<Room> {
        return UpdateRoomSettingsResource(roomId: roomId, settings: settings).rx.request
    }

    static func latestMessageIn(rooms: [Room]) -> Observable<[Room: Room.Message?]> {
        
        if rooms.count == 0 {
            return .just([:])
        }
        
        return Observable.zip(rooms.map { x -> Observable<PFObject?> in
                let q = Room.Message.query
                    .order(byDescending: "createdAt")
                    .whereKey("roomId", equalTo: x.id)
            
                q.limit = 1
            
                return q.rx.fetchFirstObject().asObservable()
            })
            .flatMap { (maybeMessages: [PFObject?]) -> Observable<[Room: Room.Message?]> in
        
                let nativeMessages: [Room.Message?] = maybeMessages.map { $0?.toCodable() }
                
                var result: [Room: Room.Message?] = [:]
                for room in rooms {
                    result[room] = nativeMessages.first { $0?.roomId == room.id } ?? (nil as Room.Message?)
                }
                
                return RoomManager.subscribeTo(rooms: rooms)
                    .map { (message, room) in
                        result[room] = message
                        return result
                    }
                    .startWith(result)
                
            }
    
    }
    
    ///Subscribe to new messages in room
    static func subscribeTo(rooms: [Room]) -> Observable<(Room.Message, Room)> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let query = PFQuery(className: Room.Message.className)
            
            query.addDescendingOrder("updatedAt")
            query.whereKey("roomId", containedIn: rooms.map { $0.id })
            
            ///this is really stupid
            ///Parse Client differentiates between susbscription based on their internal PFQuery.state
            ///it could happen that multiple callers want to listen to the same type of Query
            ///for example if there's a single room in list and chat for that room
            ///Parse will kill both subscription upon unsubscribe
            ///so we need somehow to mark queries as different
            query.whereKey("objectId", notEqualTo: UUID().uuidString)

            let subscription: Subscription<PFObject> = Client.shared.subscribe(query)
            
            subscription.handleEvent { _, e in
                
                if case .created(let pfMessage) = e {
                    
                    let nativeMessage: Room.Message = pfMessage.toCodable()
                    
                    guard let room = rooms.first(where: { $0.id == nativeMessage.roomId }) else { return }
                        
                    subscriber.onNext( (nativeMessage, room) )
                    
                }
                
            }
            
            subscription.handleError { (_, error) in
                subscriber.onError(error)
            }

            return Disposables.create {
                Client.shared.unsubscribe(query)
            }
        }
    }

}
