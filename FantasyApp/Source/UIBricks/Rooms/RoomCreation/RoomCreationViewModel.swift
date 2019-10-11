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
import RxDataSources

struct RoomCreationViewModel: MVVM_ViewModel {

    struct CellModel: IdentifiableType, Equatable {
        let thumbnailURL: String
        let isAdmin: Bool
        let name: String
        let identifier: String

        var identity: String {
            return identifier
        }
    }

    let router: RoomCreationRouter
    let room: Chat.Room
    let inviteLink = BehaviorRelay<String?>(value: nil)
    private let users = BehaviorRelay<[User]>(value: [User.current!])
    fileprivate let indicator: ViewIndicator = ViewIndicator()

    var dataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        return users.asDriver().map { users in
            let models = users.map { user in
                CellModel(thumbnailURL: user.bio.photos.avatar.thumbnailURL,
                          isAdmin: self.room.ownerId == user.id,
                          name: user.bio.name,
                          identifier: user.id)
            }
            return [AnimatableSectionModel(model: "", items: models)]
        }
    }

    init(router: RoomCreationRouter, room: Chat.Room) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        generateInviteLink()
        loadParticipants()
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

    private func loadParticipants() {
        Single.zip(room.participants.map { UserManager.getUser(id: $0.userId) })
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { users in
                self.users.accept(users.compactMap { $0 })
            })
            .disposed(by: bag)
    }

    fileprivate let bag = DisposeBag()
}
