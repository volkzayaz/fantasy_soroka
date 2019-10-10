//
//  ChatManager.swift
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

enum ChatManager {
    enum ChatEvent {
        case messageAdded(Chat.Message)
        case messageRemoved(Chat.Message)
        case messageUpdated(Chat.Message)
    }
    private static var messagesQuery: PFQuery<PFObject> = PFQuery(className: Chat.Message.className)
}

extension ChatManager {
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
        query.whereKey("backendId", containedIn: rooms.map { $0.id! })
        return query.rx.fetchAll().map { (roomDetails: [Chat.RoomDetails]) in
            let populatedRooms: [Chat.Room] = rooms.map { room in
                var populatedRoom = room
                populatedRoom.details = roomDetails.first(where: { $0.backendId == room.id })
                return populatedRoom
            }
            Dispatcher.dispatch(action: SetRooms(rooms: populatedRooms))
            return populatedRooms
        }
    }

    static func getRooms() -> Single<[Chat.Room]?> {
        return RoomsResource().rx.request.map { $0 }.asObservable()
            .flatMapLatest { rooms -> Observable<[Chat.Room]> in
            Dispatcher.dispatch(action: SetRooms(rooms: rooms))
            return getDetails(for: rooms).asObservable()
        }.first()
    }

    // MARK: - Room creation
    static func createDraftRoom() -> Single<Chat.Room?> {
        let settings = Chat.RoomSettings(isClosedRoom: true,
                                         isHideCommonFantasies: true,
                                         isScreenShieldEnabled: false,
                                         sharedCollections: [])
        return CreateDraftRoomResource(settings: settings).rx.request
            .asObservable()
            .flatMapLatest { room -> Observable<Chat.Room> in
                Dispatcher.dispatch(action: AddRooms(rooms: [room]))
                return createDraftRoomDetails(for: room).asObservable()
            }.first()
    }

    static func activateRoom(_ roomId: String) -> Single<Chat.Room> {
        return ActivateRoomResource(roomId: roomId).rx.request.map { $0 }
    }

    // MARK: - Room Details (Parse)
    private static func createDraftRoomDetails(for room: Chat.Room) -> Single<Chat.Room> {
        let roomDetails = Chat.RoomDetails(objectId: nil,
                                           ownerId: AuthenticationManager.currentUser()!.id,
                                           recipientId: nil,
                                           updatedAt: nil,
                                           lastMessage: nil,
                                           backendId: room.id)
        return roomDetails.rxCreate().map { _ in return room }
    }

    private static func updateLastMessage(_ message: Chat.Message, in room: Chat.Room) {
        guard var details = room.details,
            message.senderId == AuthenticationManager.currentUser()?.id else {
                return
        }

        details.lastMessage = message.text

        _ = details.rxSave().map { _ in }
    }

    // MARK: - Invite user
    static func inviteParticipant(_ participant: Chat.RoomParticipant, to roomId: String) -> Single<Chat.Room> {
        return InviteParticipantResource(roomId: roomId, participant: participant).rx.request.map { $0 }
    }

    // MARK: - Accept invitation
    static func acceptInviteToRoom(_ roomId: String) -> Single<Chat.Room> {
        return AcceptInviteResource(roomId: roomId).rx.request.map { $0 }
    }

    // MARK: - Connect/disconnect
    static func connectToRoom(_ room: Chat.Room) -> Observable<ChatEvent> {
        return Observable.create { (subscriber) -> Disposable in
            messagesQuery.addDescendingOrder("updatedAt")
            messagesQuery.whereKey("roomId", equalTo: room.id!)

            let subscription: Subscription<PFObject> = Client.shared.subscribe(messagesQuery)
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

            return Disposables.create()
        }
    }

    static func disconnectFromRoom(_ roomId: String) {
        messagesQuery.addDescendingOrder("updatedAt")
        messagesQuery.whereKey("roomId", equalTo: roomId)

        Client.shared.unsubscribe(messagesQuery)
    }
}
