//
//  ChatViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ParseLiveQuery
import Chatto
import ChattoAdditions

class ChatViewModel: MVVM_ViewModel, ChatDataSourceProtocol {
    
    let router: ChatRouter
    let room: Room
    let messages = BehaviorRelay<[Room.Message]>(value: [])
    weak var delegate: ChatDataSourceDelegateProtocol?
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()

    init(router: ChatRouter, room: Room) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        loadMessages()
    }

    func loadNext() {}
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {}

    func loadPrevious() {
        //loadMessages()
    }

    var chatItems: [ChatItemProtocol] {
        return prepareChatItems()
    }

    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return true
    }
}

extension ChatViewModel {
    
    func loadMessages() {
        RoomManager.getMessagesInRoom(room.id, offset: messages.value.count)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [weak self] messages in
                guard let self = self else { return }
                var array = self.messages.value
                array.append(contentsOf: messages)
                self.messages.accept(messages)
                self.connect()
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .firstLoad)
            })
            .disposed(by: bag)
    }

    func sendMessage(text: String) {
        let message = Room.Message(text: text,
                                   from: User.current!,
                                   in: room)
                                   
        RoomManager.sendMessage(message, to: room).subscribe({ event in
            // TODO: error handling
        }).disposed(by: bag)
    }

    func connect() {
        
        RoomManager.subscribeTo(rooms: [room]).subscribe(onNext: { [weak self] (message, _) in
            
            guard let self = self else { return }
            
            var array: [Room.Message] = self.messages.value
            array.append(message)
            
            self.messages.accept(array)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
            }
            
        }).disposed(by: bag)
        
    }

    private func prepareChatItems() -> [ChatItemProtocol] {
        var dateToCompare = Date()
        var adjustment = 0
        let array = messages.value
        // build message cell models
        var result: [ChatItemProtocol] = messages.value.map { TextMessageModel(messageModel: $0, text: $0.text) }
        // build time separator cell models
        array.enumerated().forEach { index, message in
            if index == 0 || message.createdAt.compare(with: dateToCompare, by: .day) != 0 {
                let model = TimeSeparatorModel(uid: UUID().uuidString, date: message.createdAt.toWeekDayAndDateString())
                result.insert(model, at: index + adjustment)
                dateToCompare = message.createdAt
                adjustment += 1
            }
        }
        return result
    }
}

enum Chat {}
// MARK: - Cells
extension Chat {
    enum CellType: String {
        case text = "text-chat-message"
        case emoji = "emoji-chat-message"
        case timeSeparator = "time-separator"
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
