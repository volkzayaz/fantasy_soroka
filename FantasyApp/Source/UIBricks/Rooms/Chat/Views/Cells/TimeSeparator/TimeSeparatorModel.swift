//
//  TimeSeparatorModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 30.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import UIKit
import Chatto

class TimeSeparatorModel: ChatItemProtocol {
    let uid: String
    let type: String = TimeSeparatorModel.chatItemType
    let date: String

    static var chatItemType: ChatItemType {
        return Chat.CellType.timeSeparator.rawValue
    }

    init(uid: String, date: String) {
        self.date = date
        self.uid = uid
    }
}
