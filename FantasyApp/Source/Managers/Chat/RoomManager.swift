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

enum RoomManager {
    enum ChatEvent {
        case messageAdded(Chat.Message)
        case messageRemoved(Chat.Message)
        case messageUpdated(Chat.Message)
    }
}

extension RoomManager {
    // MARK: - Messages
    static func sendMessage(_ message: Chat.Message, to room: Chat.Room) -> Single<Void> {
        return message.rxCreate().map { _ in }
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Single<[Chat.Message]> {
        let query = PFQuery(className: Chat.Message.className)
        query.whereKey("roomId", equalTo: roomId)
        query.addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = limit

        return query.rx.fetchAll()
    }

    // MARK: - Rooms fetching
    private static func getDetails(for rooms: [Chat.Room]) -> Single<[Chat.Room]> {
        let query = PFQuery(className: Chat.RoomDetails.className)
        query.whereKey("backendId", containedIn: rooms.map { $0.id })
        return query.rx.fetchAll().map { (roomDetails: [Chat.RoomDetails]) in
            let populatedRooms: [Chat.Room] = rooms.map { room in
                var populatedRoom = room
                populatedRoom.details = roomDetails.first(where: { $0.backendId == room.id })
                return populatedRoom
            }
            return populatedRooms
        }
    }

    // MARK: - Rooms fetching
    private static func getNotificationSettings(for rooms: [Chat.Room]) -> Single<[Chat.Room]> {
        let query = PFQuery(className: RoomNotificationSettings.className)
        query.whereKey("roomId", containedIn: rooms.map { $0.id })
        return query.rx.fetchAll().map { (settings: [RoomNotificationSettings]) in
            let populatedRooms: [Chat.Room] = rooms.map { room in
                var populatedRoom = room
                populatedRoom.notificationSettings = settings.first(where: { $0.roomId == room.id })
                return populatedRoom
            }
            return populatedRooms
        }
    }

    static func getAllRooms() -> Single<[Chat.Room]> {
        return RoomsResource().rx.request
            .flatMap { rooms -> Single<[Chat.Room]> in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
                return getDetails(for: rooms)
            }
            .flatMap { rooms -> Single<[Chat.Room]> in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
                return getNotificationSettings(for: rooms)
            }
            .do(onSuccess: { rooms in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
            })
    }

    static func getRoom(id: String) -> Single<Chat.Room> {
        
        if let room = appStateSlice.rooms.first(where: { $0.id == id }) {
            return .just(room)
        }
        
        return RoomResource(id: id).rx.request
            .flatMap { room in
                return getDetails(for: [room])
            }
            .map { $0.first! }
    }

    // MARK: - Room creation
    static func createDraftRoom() -> Single<Chat.Room> {
        let settings = Chat.RoomSettings(isClosedRoom: true,
                                         isHideCommonFantasies: false,
                                         isScreenShieldEnabled: false,
                                         sharedCollections: [])
        return CreateDraftRoomResource(settings: settings).rx.request
            .asObservable()
            .flatMapLatest { room -> Observable<Chat.Room> in
                Dispatcher.dispatch(action: AddRooms(rooms: [room]))
                return createDraftRoomDetails(for: room).asObservable()
            }
            .flatMapLatest { room -> Observable<Chat.Room> in
                return createRoomNotificationSettings(for: room).asObservable()
            }
            .flatMapLatest { room -> Observable<Chat.Room> in
                return inviteUser(to: room.id).asObservable()
            }.asSingle()
    }

    static func createRoomWithUser(_ userId: String) -> Single<Chat.Room> {
        let settings = Chat.RoomSettings(isClosedRoom: true,
                                         isHideCommonFantasies: false,
                                         isScreenShieldEnabled: false,
                                         sharedCollections: [])
        return CreateDraftRoomResource(settings: settings).rx.request
            .asObservable()
            .flatMapLatest { room -> Observable<Chat.Room> in
                Dispatcher.dispatch(action: AddRooms(rooms: [room]))
                return createDraftRoomDetails(for: room).asObservable()
            }
            .flatMapLatest { room -> Observable<Chat.Room> in
                return inviteUser(userId, to: room.id).asObservable()
            }.asSingle()
    }

    static func activateRoom(_ roomId: String) -> Single<Chat.Room> {
        return ActivateRoomResource(roomId: roomId).rx.request.map { $0 }
    }

    // MARK: - Room Details (Parse)
    private static func createDraftRoomDetails(for room: Chat.Room) -> Single<Chat.Room> {
        let roomDetails = Chat.RoomDetails(objectId: nil,
                                           backendId: room.id,
                                           updatedAt: nil,
                                           lastMessage: nil)
                                           
        return roomDetails.rxCreate().map { _ in return room }
    }

    private static func createRoomNotificationSettings(for room: Chat.Room) -> Single<Chat.Room> {
        let roomSettings = RoomNotificationSettings(objectId: nil,
                                                   roomId: room.id,
                                                   newMessage: true,
                                                   newFantasyMatch: true)
        return roomSettings.rxCreate().map { settings in
            Dispatcher.dispatch(action: AddRoomNotificationSettings(settings: settings))
            return room
        }
    }

    private static func updateLastMessage(_ message: Chat.Message, in room: Chat.Room) {
        guard var details = room.details,
            message.senderId == AuthenticationManager.currentUser()?.id else {
                return
        }

        details.lastMessage = message.text

        _ = details.rxSave().map { _ in }
    }

    // MARK: - Invites
    static func inviteUser(_ userId: String? = nil, to roomId: String) -> Single<Chat.Room> {
        return InviteParticipantResource(roomId: roomId, userId: userId).rx.request.map { $0 }
    }

    static func acceptInviteToRoom(_ invitationLink: String) -> Single<Chat.Room> {
        return RoomByInvitationTokenResource(token: invitationLink).rx.request
            .asObservable()
            .flatMapLatest { room -> Observable<Chat.Room> in
                return respondToInvite(in: room.id, status: .accepted).asObservable()
            }
            .asSingle()
    }

    static func respondToInvite(in roomId: String, status: Chat.RoomParticipantStatus) -> Single<Chat.Room> {
        return RoomStatusResource(roomId: roomId, status: status).rx.request
    }

    // MARK: - Settings
    static func updateRoomSettings(roomId: String, settings: Chat.RoomSettings) -> Single<Chat.Room> {
        return UpdateRoomSettingsResource(roomId: roomId, settings: settings).rx.request
    }

    // MARK: - Connect/disconnect
    static func connectToRoom(_ room: Chat.Room) -> Observable<ChatEvent> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let query = PFQuery(className: Chat.Message.className)
            
            query.addDescendingOrder("updatedAt")
            query.whereKey("roomId", equalTo: room.id)

            let subscription: Subscription<PFObject> = Client.shared.subscribe(query)
            subscription.handleEvent { object, e in
                var event: ChatEvent
                switch e {
                case .entered(let messageObject), .created(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageAdded(message)
                    updateLastMessage(message, in: room)
                case .deleted(let messageObject), .left(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageRemoved(message)
                case .updated(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageUpdated(message)
                }
                subscriber.onNext(event)
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
