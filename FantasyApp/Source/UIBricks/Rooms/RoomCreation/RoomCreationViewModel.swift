//
//  RoomCreationViewModel.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Branch

struct RoomCreationViewModel: MVVM_ViewModel {
    let router: RoomCreationRouter
    let room: Chat.Room
    let inviteLink = BehaviorRelay<String?>(value: nil)
    fileprivate let indicator: ViewIndicator = ViewIndicator()

    init(router: RoomCreationRouter, room: Chat.Room) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        generateInviteLink()
    }

    private func generateInviteLink() {
        let buo = BranchUniversalObject(canonicalIdentifier: "room/\(room.id!)")
        buo.title = "Fantasy"
        buo.contentDescription = "Join my room!"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["roomId"] = room.id

        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.addControlParam("roomId", withValue: room.id)

        buo.getShortUrl(with: lp) { (url, error) in
            self.inviteLink.accept(url)
        }
    }

    fileprivate let bag = DisposeBag()
}
