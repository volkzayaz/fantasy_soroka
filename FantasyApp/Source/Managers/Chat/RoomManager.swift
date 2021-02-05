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

protocol RoomIdentifier {
    var id: String { get }
}

extension Room: RoomIdentifier {}
extension RoomRef: RoomIdentifier {}
extension String: RoomIdentifier {
}

enum RoomManager {}

extension RoomManager {
    
    static func sendMessage(_ message: Room.MessageInRoom) -> Single<Room.MessageInRoom> {
        return webSocket.send(message: message)
    }
    
    static func markRead(message: Room.Message, in room: RoomIdentifier) -> Single<Room.MessageInRoom> {
        return webSocket.send(readStatus: Room.ReadStatus(roomId: room.id,
                                                          userId: User.current!.id,
                                                          messageId: message.messageId))
            .map { _ in
                var x = message
                x.markRead()
                return Room.MessageInRoom(raw: x, roomId: room.id)
            }
    }

    static func getMessagesInRoom(_ roomId: String) -> Single<[Room.Message]> {
        return MesagesIn(room: roomId).rx.request
            .map { $0.messages
//                .filter { $0.type == .message }
        }
        
    }
    
    static func getAllRooms() -> Single<[Room]> {
        return RoomsResource().rx.request
    }

    static func getRoom(id: String) -> Single<Room> {
        
        if let room = appStateSlice.rooms?.first(where: { $0.id == id }) {
            return .just(room)
        }
        
        return RoomResource(id: id).rx.request
    }
    
    static func room(with: UserIdentifier) -> Single<Room?> {
        
        if let rooms = appStateSlice.rooms {
            return .just( rooms.first(where: { $0.peer.userSlice?.id == with.id }) )
        }
        
        return getAllRooms()
            .map { $0.first(where: { $0.peer.userSlice?.id == with.id }) }
    }

    // MARK: - Room creation
    static func createDraftRoom(collections: [String] = []) -> Single<Room> {
        
        let settings = Room.Settings(isClosedRoom: true,
                                     isHideCommonFantasies: false,
                                     isScreenShieldEnabled: User.current?.subscription.isSubscribed ?? false,
                                     sharedCollections: collections,
                                     notifications: .init(newMessage: true,
                                                          newFantasyMatch: true)
                                     )
        return CreateDraftRoomResource(settings: settings).rx.request
            .flatMap { room in
                return inviteUser(nil, to: room.id)
            }
    }
    
    static func createEmptyRoom() {
        
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
    
    static func updateRoomSharedCollections(room: Room) -> Single<Room> {
        return UpdateRoomSharedCollectionsResource(room: room).rx.request
    }

    static func latestMessageIn(rooms: [Room]) -> Observable<Room.MessageInRoom> {
        
        if rooms.count == 0 {
            return .empty()
        }
         
        return webSocket.didReceiveMessage
            .filter { x in rooms.contains(where: { $0.id == x.roomId }) }
            
    }

    static func subscribeToMessages(in room: Room) -> Observable<Room.Message> {
        return webSocket.didReceiveMessage(in: room)
            .map { $0.raw }
    }

}
