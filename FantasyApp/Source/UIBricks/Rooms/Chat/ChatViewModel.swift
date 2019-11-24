//
//  ChatViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

extension ChatViewModel {
    
    var inputEnabled: Driver<Bool> {
        return room
            .asDriver()
            .map { !$0.isWaitingForMyResponse }
    }
    
    var dataSource: Driver<[AnimatableSectionModel<String, Row>]> {
        
        let requestTypes = ConnectionManager.requestTypes(with: room.value.peer.userSlice.id)
                                .asDriver(onErrorJustReturn: [])
        
        return Driver.combineLatest(requestTypes, mes.asDriver(), room.asDriver())
            .map { requestTypes, messages, room in
                
                var items = messages.map { Row.message($0) }
                
                if room.isWaitingForMyResponse {
                    items.append(.acceptReject)
                }
                else if !room.isDraftRoom {
                    items.append(.roomCreated)
                }
                
                items.append(.connection(requestTypes))
                
                return [AnimatableSectionModel(model: "",
                                               items: items)]
            }
        
    }
    
    var peerAvatar: Driver<UIImage> {
        return ImageRetreiver.imageForURLWithoutProgress(url: room.value.peer.userSlice.avatarURL)
            .map { $0 ?? R.image.noPhoto()! }
    }
    
    var initiator: Room.Participant.UserSlice {
        
        if room.value.ownerId == User.current?.id {
            return room.value.me.userSlice
        }
        
        return room.value.peer.userSlice
    }
    
    var slicePair: (left: Room.Participant.UserSlice, right: Room.Participant.UserSlice) {
        return (room.value.me.userSlice, room.value.peer.userSlice)
    }
    
    mutating func position(for message: Room.Message) -> MessageCellPosition {
        if let x = heightCache[message.text] {
            return x
        }
        
        heightCache[message.text] = .init(message: message)
        return position(for: message)
    }
    
    enum Row: IdentifiableType, Equatable {
        case message(Room.Message)
        case connection(Set<ConnectionRequestType>)
        case acceptReject
        case roomCreated
        
        var identity: String {
            switch self {
            case .message(let m): return m.objectId ?? ""
            case .connection(_): return "connection"
            case .acceptReject: return "acceptReject"
            case .roomCreated: return "roomCreated"
            }
        }
    }
    
}

struct ChatViewModel: MVVM_ViewModel {
    
    private let room: SharedRoomResource
    private var heightCache: [String: MessageCellPosition] = [:]
    
    private let mes = BehaviorRelay<[Room.Message]>(value: [])
    
    init(router: ChatRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room

        RoomManager.getMessagesInRoom(room.value.id, offset: 0)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .flatMap { mes -> Observable<[Room.Message]> in

                return RoomManager.subscribeTo(rooms: [room.value])
                    .scan(mes, accumulator: { (res, messageInRoom) in [messageInRoom.0] + res })
                    .startWith(mes)
            }
            .bind(to: mes)
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
    
    func presentInitiator() {
        
        UserManager.getUser(id: initiator.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { user in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
            
    }
    
    func presentPeer() {
        
        UserManager.getUser(id: room.value.peer.userSlice.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { user in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
        
    }
    
}
