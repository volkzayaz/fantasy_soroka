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
    
    private(set) var room: Room
    
    let chattoMess: ChattoMess
    
    private let inputEnabledRelay: BehaviorRelay<Bool>
    
    init(router: ChatRouter, room: Room, chattoDelegate: ChatDataSourceDelegateProtocol) {
        self.router = router
        self.room = room
        self.chattoMess =  {
            let x = ChattoMess()
            x.delegate = chattoDelegate
            return x
        }()
        
        chattoMess.includesAcceptReject = room.participants.contains { $0.status == .invited && $0.userId == User.current?.id }
        
        inputEnabledRelay = .init(value: !chattoMess.includesAcceptReject)
        
        RoomManager.getMessagesInRoom(room.id, offset: 0)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .flatMap { mes -> Observable<[Room.Message]> in

                return RoomManager.subscribeTo(rooms: [room])
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
                                   in: room)
                                   
        RoomManager.sendMessage(message, to: room)
            .subscribe({ event in
            // TODO: error handling
            }).disposed(by: bag)
    }
    
    func acceptRequest() {
        let _ = ConnectionManager.likeBack(user: room.ownerId)
            .subscribe()
        
        var x = room.participants.first!
        x.status = .accepted
        room.participants[0] = x
        chattoMess.includesAcceptReject = false
        inputEnabledRelay.accept(true)
    }
    
    func rejectRequest() {
        
        ConnectionManager.reject(user: room.ownerId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in
                self.router.owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
    }
    
}
