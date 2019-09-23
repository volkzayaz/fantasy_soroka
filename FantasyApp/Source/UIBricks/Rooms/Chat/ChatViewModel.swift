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
import MessageKit
import ParseLiveQuery

struct ChatViewModel: MVVM_ViewModel {
    let router: ChatRouter
    let room: Chat.Room
    let messages = BehaviorRelay<[Chat.Message]>(value: [])
    let isSendingMessage = BehaviorRelay<Bool>(value: false)

    init(router: ChatRouter, room: Chat.Room) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension ChatViewModel {
    var currentSender: Sender {
        return Sender(senderId: User.current!.id, displayName: User.current!.bio.name)
    }

    func loadMessages() {
        // TODO: Pagination and error handling
        let offset = 0
        ChatManager.getMessagesInRoom(room.objectId, offset: offset)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { messages in
                var array = self.messages.value
                array.insert(contentsOf: messages, at: offset)
                self.messages.accept(messages)
                self.connect()
            })
            .disposed(by: bag)
    }

    func sendMessage(text: String) {
        isSendingMessage.accept(true)
        let message = Chat.Message(senderDisplayName: User.current!.bio.name,
                                   senderId: AuthenticationManager.currentUser()!.id,
                                   recepientId: room.recipient?.objectId,
                                   updatedAt: nil,
                                   text: text,
                                   objectId: nil,
                                   roomId: room.objectId,
                                   isRead: false)
        ChatManager.sendMessage(message).subscribe({ event in
            // TODO: error handling
            self.isSendingMessage.accept(false)
        }).disposed(by: bag)
    }

    func connect() {
        ChatManager.connect(roomId: room.objectId).subscribe(onNext: { event in
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
        }).disposed(by: bag)
    }

    func disconnect() {
        ChatManager.disconnect(roomId: room.objectId)
    }
}
