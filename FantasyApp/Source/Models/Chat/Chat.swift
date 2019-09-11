//
//  Chat.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Parse

enum Chat {}
extension Chat {

    struct Message: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "SinchMessage"
        }

        var pfObjectId: String {
            return objectId
        }

        var identity: String {
            return pfObjectId
        }

        var senderId: String?
        var recepientId: String?
        var updatedAt: Date?
        var text: String?
        var messageId: String?
        var objectId: String!
        var roomId: String?
    }


    struct Room: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "Room"
        }

        var pfObjectId: String {
            return objectId
        }

        var identity: String {
            return pfObjectId
        }

        var objectId: String!
        var updatedAt: Date?
        var owner: UserSlice?
        var recipient: UserSlice?
        var messages: [Message]?
    }
}
