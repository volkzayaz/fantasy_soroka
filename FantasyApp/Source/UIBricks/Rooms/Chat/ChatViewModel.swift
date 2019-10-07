//
//  ChatViewModel.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
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
    let room: Chat.RoomDetails
    let messages = BehaviorRelay<[Chat.Message]>(value: [])
    weak var delegate: ChatDataSourceDelegateProtocol?
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()

    init(router: ChatRouter, room: Chat.RoomDetails) {
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
        ChatManager.getMessagesInRoom(room.objectId!, offset: messages.value.count)
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
        guard let roomId = room.objectId, let recepientId = room.recipient?.objectId else {
            return
        }
        let message = Chat.Message(senderDisplayName: User.current!.bio.name,
                                   senderId: AuthenticationManager.currentUser()!.id,
                                   recepientId: recepientId,
                                   text: text,
                                   objectId: nil,
                                   roomId: roomId,
                                   isRead: false,
                                   createdAt: Date())
        ChatManager.sendMessage(message).subscribe({ [weak self] event in
            guard let self = self else { return }
            // TODO: error handling
        }).disposed(by: bag)
    }

    func connect() {
        guard let roomId = room.objectId else {
            return
        }
        ChatManager.connect(roomId: roomId).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            var array: [Chat.Message] = self.messages.value
            switch event {
            case .messageAdded(let message):
                array.append(message)
            case .messageRemoved(let message):
                array.removeAll { message.objectId == $0.objectId }
            case .messageUpdated(let message):
                if let index = array.firstIndex(where: { message.objectId == $0.objectId }) {
                    array[index] = message
                }
            }
            self.messages.accept(array)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
            }
        }).disposed(by: bag)
    }

    func disconnect() {
        guard let roomId = room.objectId else {
            return
        }
        ChatManager.disconnect(roomId: roomId)
    }

    private func prepareChatItems() -> [ChatItemProtocol] {
        var dateToCompare = Date()
        var adjustment = 0
        let array = messages.value
        // build message cell models
        var result: [ChatItemProtocol] = messages.value.map { TextMessageModel(messageModel: $0, text: $0.text ?? "") }
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
