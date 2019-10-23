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

    // MARK: - Rooms fetching
    private static func getNotificationSettings(for rooms: [Room]) -> Single<[Room]> {
        let query = PFQuery(className: RoomNotificationSettings.className)
        query.whereKey("roomId", containedIn: rooms.map { $0.id })
        return query.rx.fetchAll().map { (settings: [RoomNotificationSettings]) in
            let populatedRooms: [Room] = rooms.map { room in
                var populatedRoom = room
                populatedRoom.notificationSettings = settings.first(where: { $0.roomId == room.id })
                return populatedRoom
            }
            return populatedRooms
        }
    }

    static func getAllRooms() -> Single<[Room]> {
        return RoomsResource().rx.request
            .flatMap { rooms -> Single<[Room]> in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
                return getNotificationSettings(for: rooms)
            }
            .do(onSuccess: { rooms in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
            })
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
                                         isScreenShieldEnabled: false,
                                         sharedCollections: [])
        return CreateDraftRoomResource(settings: settings).rx.request
            .flatMap { room -> Single<Room> in
                Dispatcher.dispatch(action: AddRooms(rooms: [room]))
                return createRoomNotificationSettings(for: room)
            }
            .flatMap { room -> Single<Room> in
                return inviteUser(nil, to: room.id)
            }
    }

    static func createRoomWithUser(_ userId: String) -> Single<Room> {
        let settings = Room.Settings(isClosedRoom: true,
                                         isHideCommonFantasies: false,
                                         isScreenShieldEnabled: false,
                                         sharedCollections: [])
        return CreateDraftRoomResource(settings: settings).rx.request
            .flatMap { room in
                Dispatcher.dispatch(action: AddRooms(rooms: [room]))
                return inviteUser(userId, to: room.id)
            }
    }

    static func activateRoom(_ roomId: String) -> Single<Room> {
        return ActivateRoomResource(roomId: roomId).rx.request.map { $0 }
    }

    private static func createRoomNotificationSettings(for room: Room) -> Single<Room> {
        let roomSettings = RoomNotificationSettings(objectId: nil,
                                                   roomId: room.id,
                                                   newMessage: true,
                                                   newFantasyMatch: true)
        return roomSettings.rxCreate().map { settings in
            Dispatcher.dispatch(action: AddRoomNotificationSettings(settings: settings))
            return room
        }
    }

    // MARK: - Invites
    static func inviteUser(_ userId: String? = nil, to roomId: String) -> Single<Room> {
        return InviteParticipantResource(roomId: roomId, userId: userId).rx.request
    }

    static func acceptInviteToRoom(_ invitationLink: String) -> Single<Room> {
        return RoomByInvitationTokenResource(token: invitationLink).rx.request
            .asObservable()
            .flatMapLatest { room -> Observable<Room> in
                return respondToInvite(in: room.id, status: .accepted).asObservable()
            }
            .asSingle()
    }

    static func respondToInvite(in roomId: String, status: Room.Participant.Status) -> Single<Room> {
        return RoomStatusResource(roomId: roomId, status: status).rx.request
    }

    // MARK: - Settings
    static func updateRoomSettings(roomId: String, settings: Room.Settings) -> Single<Room> {
        return UpdateRoomSettingsResource(roomId: roomId, settings: settings).rx.request
    }

    ///Subscribe to new messages in room
    static func subscribeTo(rooms: [Room]) -> Observable<(Room.Message, Room)> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let query = PFQuery(className: Room.Message.className)
            
            query.addDescendingOrder("updatedAt")
            query.whereKey("roomId", containedIn: rooms.map { $0.id })

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
