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
    private var query: PFQuery<PFObject> = PFQuery(className: Chat.Message.className)

    init(router: ChatRouter, room: Chat.Room) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        addSubscription()
    }

    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension ChatViewModel {
    var currentSender: Sender {
        return Sender(senderId: AuthenticationManager.currentUser()!.id,
                      displayName: AuthenticationManager.currentUser()!.bio.name)
    }

    func loadMessages() {
        // TODO: Pagination
        let offset = 0
        ChatManager.getMessagesInRoom(room.objectId, offset: offset)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { messages in
                var array = self.messages.value
                array.insert(contentsOf: messages, at: offset)
                self.messages.accept(messages)
            })
            .disposed(by: bag)
    }

    func sendMessage(text: String) {
        isSendingMessage.accept(true)
        let message = Chat.Message(senderDisplayName: AuthenticationManager.currentUser()!.bio.name,
                                   senderId: AuthenticationManager.currentUser()!.id,
                                   recepientId: room.recipient?.objectId,
                                   updatedAt: nil,
                                   text: text,
                                   objectId: nil,
                                   roomId: room.objectId,
                                   isRead: false)
        ChatManager.sendMessage(message)
            .subscribe({ event in
                // TODO: error handling
                self.isSendingMessage.accept(false)
            })
            .disposed(by: bag)
    }
}

private extension ChatViewModel {
    func addSubscription() {
        query.addDescendingOrder("updatedAt")
        query.whereKey("roomId", equalTo: room.objectId as String)

        let subscription: Subscription<PFObject> = Client.shared.subscribe(query)
        subscription.handleEvent { object, event in
            var array: [Chat.Message] = self.messages.value
            switch event {
            case .entered(let messageObject), .created(let messageObject):
                let message: Chat.Message = [messageObject].toCodable().first!
                array.append(message)
            case .deleted(let messageObject), .left(let messageObject):
                let message: Chat.Message = [messageObject].toCodable().first!
                array.removeAll { message.objectId == $0.objectId }
            case .updated(let messageObject):
                let message: Chat.Message = [messageObject].toCodable().first!
                if let index = array.firstIndex(where: { message.objectId == $0.objectId }) {
                    array[index] = message
                }
            }
            self.messages.accept(array)
        }
    }
}
