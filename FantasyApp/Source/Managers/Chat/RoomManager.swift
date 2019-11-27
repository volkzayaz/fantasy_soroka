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
    
    static func sendMessage(_ message: Room.MessageInRoom, in room: Room) -> Single<Void> {
        
        if let id = room.peer.userId {
            PushManager.sendPush(to: id,
                                 text: "\(User.current!.bio.name) sent you a message" )
        }
        
        return webSocket.send(message: message)
            .map { _ in }
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Single<[Room.Message]> {
        return MesagesIn(room: roomId).rx.request
            .map { $0.messages }
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
         
        let access = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })
        var result: [Room: Room.Message?] = Dictionary(uniqueKeysWithValues: rooms.map { ($0, $0.lastMessage) })
        
        return webSocket.didReceiveMessage
            .filter { access[$0.roomId] != nil }
            .map { message in
                result[access[message.roomId]!] = message.raw
                return result
            }
            .startWith(result)
            
    }

    static func subscribeToMessages(in room: Room) -> Observable<Room.Message> {
        return webSocket.didReceiveMessage(in: room)
            .map { $0.raw }
    }

}
