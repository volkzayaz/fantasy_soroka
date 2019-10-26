//
//  ChattoMess.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/24/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import Chatto
import ChattoAdditions

class ChattoMess: ChatDataSourceProtocol {
    
    var includesAcceptReject: Bool = false {
        didSet {
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        }
    }
    var messages: [Room.Message] = [] {
        didSet {
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        }
    }
    
    func loadNext() {}
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {}
    func loadPrevious() {}

    var chatItems: [ChatItemProtocol] {
        
        var dateToCompare = Date()
        var adjustment = 0
        let array = messages
        // build message cell models
        var result: [ChatItemProtocol] = messages.map { TextMessageModel(messageModel: $0, text: $0.text) }
        // build time separator cell models
        array.enumerated().forEach { index, message in
            
            if index == 0 || message.createdAt.compare(with: dateToCompare, by: .day) != 0 {
                let model = TimeSeparatorModel(uid: UUID().uuidString,
                                               date: message.createdAt.toWeekDayAndDateString())
                result.insert(model, at: index + adjustment)
                dateToCompare = message.createdAt
                adjustment += 1
            }
            
        }
        
        if includesAcceptReject {
            result.insert(AcceptRejectModel(), at: 0)
        }
        
        return result
        
    }

    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return false
    }
    
    weak var delegate: ChatDataSourceDelegateProtocol?
    
}

enum Chat {}
extension Chat {
    enum CellType: String {
        case text = "text-chat-message"
        case emoji = "emoji-chat-message"
        case timeSeparator = "time-separator"
        case acceptReject = "accept-reject"
    }
}

// MARK: - Chatto
extension Room.Message: MessageModelProtocol {
    var isIncoming: Bool {
        return senderId != User.current?.id
    }

    var date: Date {
        return createdAt
    }

    var status: MessageStatus {
        return .success
    }

    var type: ChatItemType {
        return text.containsOnlyEmojis ? Chat.CellType.emoji.rawValue :
            Chat.CellType.text.rawValue
    }

    var uid: String {
        return objectId ?? ""
    }
}

class AcceptRejectModel: NSObject, ChatItemProtocol {
    
    var type: ChatItemType {
        return Chat.CellType.acceptReject.rawValue
    }
    
    var uid: String { return "1" }
    
}

class AcceptRejectPresenter: ChatItemPresenterProtocol {
    
    unowned var viewModel: ChatViewModel!
    
    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(R.nib.acceptRejectCell)
    }
    
    var isItemUpdateSupported: Bool { return false }
    
    func update(with chatItem: ChatItemProtocol) {}
        
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 121
    }
    
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.acceptRejectCell, for: indexPath)!
        
        cell.viewModel = viewModel
        
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
}

class AcceptRejectBuilder: ChatItemPresenterBuilderProtocol {
    
    unowned var viewModel: ChatViewModel!
    
    func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem.type == Chat.CellType.acceptReject.rawValue
    }
    
    func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        let x = AcceptRejectPresenter()
        x.viewModel = viewModel
        return x
    }
    
    var presenterType: ChatItemPresenterProtocol.Type {
        return AcceptRejectPresenter.self
    }
    
}
