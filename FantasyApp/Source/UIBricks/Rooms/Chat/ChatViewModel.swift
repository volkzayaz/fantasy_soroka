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

        let connectionAndRoom = room.asDriver()
            .distinctUntilChanged { $0.participants }
            .flatMapLatest { room -> Driver<(Set<ConnectionRequestType>, Room)> in
                
                guard let peer = room.peer else {
                    return .just(([], room))
                }
                
                return ConnectionManager.requestTypes(with: peer.userSlice.id)
                    .asDriver(onErrorJustReturn: [])
                    .map { ($0, room) }
            }
        
        return Driver.combineLatest(connectionAndRoom, mes.asDriver())
            .map { t, messages in

                let requestTypes = t.0
                let room = t.1

                guard let peer = room.peer?.userSlice else { return [] }
                
                var items = [Row]()

                if room.isWaitingForMyResponse {
                    items.append(.acceptReject)
                }

                items += messages.map { x -> Row in

                    switch x.type {

                    case .created:
                        return .roomCreated(x)

                    case .like:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.outgoingRequestLike()!, event, x)

                    case .invited:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.outgoingRequestLink()!, event, x)

                    case .message:
                        return .message(x)

                    case .sp_enabled, .sp_disabled: fallthrough
                    case .settings_changed:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.roomSettingsChanged()!, event, x)

                    case .frozen:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.exclamation()!, event, x)

                    case .unfrozen:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.roomUnfrozen()!, event, x)

                    case .unfrozenPaid:
                        let event = x.typeDescription(peer: peer.name)
                        return .event(R.image.roomUnfrozen()!, event, x)

                    case .message_deleted, .deleted:
                        return .message(x)

                    }

                }

                items.append(.connection(requestTypes))

                return [AnimatableSectionModel(model: "",
                                               items: items)]
        }
        
    }
    
    var peerAvatar: Driver<UIImage> {
        
        guard let peer = room.value.peer else {
            return .just(R.image.add()!)
        }
            
        return ImageRetreiver.imageForURLWithoutProgress(url: peer.userSlice.avatarURL)
            .map { $0 ?? R.image.noPhoto()! }
    }

    var initiator: Room.Participant.UserSlice {

        if room.value.ownerId == User.current?.id {
            return room.value.me.userSlice
        }

        return room.value.peer!.userSlice
    }

    var slicePair: (left: Room.Participant.UserSlice, right: Room.Participant.UserSlice?) {
        return (room.value.me.userSlice, room.value.peer?.userSlice)
    }
    
    func position(for message: Room.Message) -> MessageCellPosition {
        if let x = heightCache[message.nonNullHackyText] {
            return x
        }
        
        heightCache[message.nonNullHackyText] = .init(message: message)
        return position(for: message)
    }
    
    enum Row: IdentifiableType, Equatable {
        case message(Room.Message)
        case connection(Set<ConnectionRequestType>)
        case acceptReject
        case roomCreated(Room.Message)
        case event(UIImage, String, Room.Message)
        
        var identity: String {
            switch self {
            case .message(let m): return m.identity
            case .connection(_): return "connection"
            case .acceptReject: return "acceptReject"
            case .roomCreated(_): return "roomCreated"
            case .event(_, _, let hash): return "event \(hash.messageId)"
            }
        }
    }
    
}

class ChatViewModel: MVVM_ViewModel {
    
    let room: SharedRoomResource
    private var heightCache: [String: MessageCellPosition] = [:]
    
    private let mes = BehaviorRelay<[Room.Message]>(value: [])
    
    init(router: ChatRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room

        RoomManager.getMessagesInRoom(room.value.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .map { $0.reversed() }
            .flatMap { mes -> Observable<[Room.Message]> in

                return RoomManager.subscribeToMessages(in: room.value)
                    .scan(mes, accumulator: { (res, message) in [message] + res })
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

        RoomManager.sendMessage(.init(text: text,
                                      from: User.current!,
                                      in: room.value))
            .map(NewMessageSent.init)
            .subscribe(onSuccess: {
                Dispatcher.dispatch(action: $0)
            })
            .disposed(by: bag)

        if let peer = room.value.peer, peer.status == .invited {

            let _ = ConnectionManager.initiate(with: peer.userId!, type: .message)
                .retry(2)
                .subscribe()

        }
        
    }
    
    func rowSeen(row: Row) {
        
        let message: Room.Message
        
        if case .message(let x) = row {
            message = x
        }
        else if case .event(_,_,let x) = row {
            message = x
        }
        else if case .roomCreated(let x) = row {
            message = x
        }
        else { return }
        
        if message.isRead { return }
        
        RoomManager.markRead(message: message, in: room.value)
            .do(onSuccess: { (updatedMessage) in
                Dispatcher.dispatch(action: MessageMakredRead(message: updatedMessage))
            })
            .subscribe(onSuccess: { [weak m = mes] (updatedMessage) in
                
                guard var copy = m?.value,
                    let i = copy.firstIndex(where: { $0.messageId == updatedMessage.raw.messageId }) else {
                    return
                }
                
                copy[i] = updatedMessage.raw
                
                m?.accept(copy)
            })
            .disposed(by: bag)
        
    }
    
    func acceptRequest() {
        
        ///mutation
        var updatedRoom = room.value
        var x = updatedRoom.me
        x.status = .accepted
        let i = updatedRoom.participants.firstIndex { $0.userId == x.userId }!
        updatedRoom.participants[i] = x
        room.accept(updatedRoom)
        
        var copy = mes.value
        copy.insert(Room.Message(messageId: "-1",
                                 text: nil,
                                 senderId: User.current!.id,
                                 createdAt: Date(),
                                 type: .created, readUserIds: [User.current!.id]),
                    at: 0)
        mes.accept(copy)
        
        let _ = ConnectionManager.likeBack(user: room.value.ownerId, context: .Room)
            .subscribe()
    }
    
    func rejectRequest() {
        
        ConnectionManager.reject(user: room.value.ownerId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] _ in
                self.router.owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
    }
    
    func presentInitiator() {
        presentUserDetails(for: initiator.id)
    }

    func presentMe() {
        presentUserDetails(for: room.value.me.userSlice.id)
    }
    
    func presentPeer() {
        
        if let peer = room.value.peer {
            return presentUserDetails(for: peer.userSlice.id)
        }
        
        ///MAX: invite user
    }

    func presentUserDetails(for userId: String) {
        UserManager.getUserProfile(id: userId)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] user in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
    }
    
}
