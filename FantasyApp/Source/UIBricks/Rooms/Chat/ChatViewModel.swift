//
//  ChatViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import RxSwift
import RxCocoa

import Chatto

extension ChatViewModel {
    
    var inputEnabled: Driver<Bool> {
        return inputEnabledRelay.asDriver()
    }
    
}

class ChatViewModel: MVVM_ViewModel {
    
    private let room: SharedRoomResource
    
    let chattoMess: ChattoMess
    
    private let inputEnabledRelay: BehaviorRelay<Bool>
    
    init(router: ChatRouter, room: SharedRoomResource, chattoDelegate: ChatDataSourceDelegateProtocol) {
        self.router = router
        self.room = room
        self.chattoMess =  {
            let x = ChattoMess()
            x.delegate = chattoDelegate
            return x
        }()
        
        chattoMess.includesAcceptReject = room.value.participants.contains { $0.status == .invited && $0.userId == User.current?.id }
        
        inputEnabledRelay = .init(value: !chattoMess.includesAcceptReject)
        
        RoomManager.getMessagesInRoom(room.value.id, offset: 0)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .flatMap { mes -> Observable<[Room.Message]> in

                return RoomManager.subscribeTo(rooms: [room.value])
                    .scan(mes, accumulator: { (res, messageInRoom) in res + [messageInRoom.0] })
                    .startWith(mes)
            }
            .subscribe(onNext: { [weak self] messages in
                guard let self = self else { return }

                self.chattoMess.messages = messages
            })
            .disposed(by: bag)

        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    let router: ChatRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension ChatViewModel {
    
    func sendMessage(text: String) {
        
        let message = Room.Message(text: text,
                                   from: User.current!,
                                   in: room.value)
                                   
        RoomManager.sendMessage(message, to: room.value)
            .subscribe({ event in
            // TODO: error handling
            }).disposed(by: bag)
        
        if room.value.peer.status == .invited {
            
            let _ = ConnectionManager.initiate(with: room.value.peer.userId!, type: .message)
                .retry(2)
                .subscribe()
            
        }
        
    }
    
    func acceptRequest() {
        
        ///mutation
        var updatedRoom = room.value
        var x = updatedRoom.me
        x.status = .accepted
        let i = updatedRoom.participants.firstIndex { $0.userId == x.userId }!
        updatedRoom.participants[i] = x
        room.accept(updatedRoom)
        
        ///reaction. Should be in inits bindings ;)
        chattoMess.includesAcceptReject = false
        inputEnabledRelay.accept(true)
        
        let _ = ConnectionManager.likeBack(user: room.value.ownerId)
            .subscribe()
    }
    
    func rejectRequest() {
        
        ConnectionManager.reject(user: room.value.ownerId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in
                self.router.owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
    }
    
}
