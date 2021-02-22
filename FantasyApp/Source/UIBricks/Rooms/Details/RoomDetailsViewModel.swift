//
//  RoomDetailsViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Branch

extension RoomDetailsViewModel {
    
    var title: String {
        
        guard let peer = room.value.peer.userSlice else {
            return R.string.localizable.roomDetailsDraft()
        }
        
        return R.string.localizable.roomDetailsRoomWith(peer.name)
    }
    
    var navigationEnabled: Driver<Bool> {
        return .just(true)
    }
    
    var isEmptyRoom: Driver<Bool> {
        return room.asDriver()
        .map { $0.status == .empty }
    }
    
    var inviteButtonHidden: Driver<Bool> {
        return room.asDriver()
            .map { $0.status == .ready || $0.status == .draft}
    }

}

///RoomResource is shared between different RoomDetails screens (Settings, Chat, Container as of 10.11.2019)
///It is not designed to be shared outised of RoomDetails stack
typealias SharedRoomResource = BehaviorRelay<Room>

class RoomDetailsViewModel: MVVM_ViewModel {
    enum DetailsPage: Int {
        case fantasies
        case chat
        case play
    }
    
    let router: RoomDetailsRouter
    let room: SharedRoomResource
    let page: BehaviorRelay<DetailsPage>
    private let buo: BranchUniversalObject?
    fileprivate let bag = DisposeBag()
    
    init(router: RoomDetailsRouter,
         room: Room,
         page: DetailsPage) {
        self.router = router
        self.room = BehaviorRelay(value: room)
        self.page = BehaviorRelay(value: page)

        self.buo = room.shareLine()
        
        if page == .play {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showPlay()
            }
        }
        
        ///
        webSocket.didReceiveRoomChange
            .filter { $0.roomId == room.id }
            .map { [unowned r = self.room] x in
                var copy = r.value
                copy.participants = x.participants
                return copy
            }
            .bind(to: self.room)
            .disposed(by: bag)
        
        ///
        webSocket.didReceiveRoomCollectionsChange
            .filter { $0.roomId == room.id }
            .map { [unowned r = self.room] x in
                var copy = r.value
                copy.settings.sharedCollections = x.collectionIds
                Dispatcher.dispatch(action: UpdateRoom(room: copy))
                return copy
            }
            .bind(to: self.room)
            .disposed(by: bag)
        
    }
}

extension RoomDetailsViewModel {
    
    func showSettins() {
        router.showSettings(room: room)
    }
    
    func showPlay() {
        router.showPlay(room: room)
    }
    
    func inviteButtonTapped() {
        
        Analytics.report(Analytics.Event.DraftRoomShared(type: .share))
        
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: R.string.localizable.roomBranchObjectDescription(),
                            from: router.owner) { (activityType, completed) in

        }
    }
    
    func presentMe() {
        
        //        let id = (room.value.ownerId == User.current?.id)
        //            ? room.value.me.id
        //            : room.value.peer.userSlice.id
        
        let id = room.value.me.id
        
        UserManager.getUserProfile(id: id)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] user in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
    }

    func presentPeer() {

        guard let id = room.value.peer.userSlice?.id else {
            
//                Analytics.report(Analytics.Event.DraftRoomShared(type: .add))
//
//                buo?.showShareSheet(with: BranchLinkProperties(),
//                                    andShareText: R.string.localizable.roomBranchObjectDescription(),
//                                    from: router.owner) { (activityType, completed) in }
            router.showInviteSheet(room: room)
            
            return;
        }
        
        UserManager.getUserProfile(id: id)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] user in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
        
    }
}
