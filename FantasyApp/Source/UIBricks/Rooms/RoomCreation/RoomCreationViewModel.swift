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

    enum CellModel: IdentifiableType, Equatable {
        case user(thumbnailURL: String, isAdmin: Bool, name: String, identifier: String)
        case invite

        var identity: String {
            switch self {
            case .user(_, _, _, let identifier):
                return identifier
            default:
                return UUID().uuidString
            }
        }
    }

    let router: RoomCreationRouter
    let room: Chat.Room
    let inviteLink = BehaviorRelay<String?>(value: nil)
    private let buo: BranchUniversalObject
    private let properties: BranchLinkProperties
    private let users = BehaviorRelay<[User]>(value: [User.current!])
    fileprivate let indicator: ViewIndicator = ViewIndicator()

    var dataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        return users.asDriver().map { users in
            var models = users.map { user in
                return CellModel.user(thumbnailURL: user.bio.photos.avatar.thumbnailURL,
                                      isAdmin: self.room.ownerId == user.id,
                                      name: user.bio.name,
                                      identifier: user.id)
            }

            // Add placeholder item
            if models.count == 1 {
                models.append(.invite)
            }
            return [AnimatableSectionModel(model: "", items: models)]
        }
    }

    init(router: RoomCreationRouter, room: Chat.Room) {
        self.router = router
        self.room = room
        self.buo = BranchUniversalObject(canonicalIdentifier: "room/\(room.id!)")
        self.properties = BranchLinkProperties()

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        generateInviteLink()
        loadParticipants()
    }

    private func generateInviteLink() {
        buo.title = "Fantasy"
        buo.contentDescription = "Join my room!"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["roomId"] = room.id
        properties.addControlParam("roomId", withValue: room.id)

        buo.getShortUrl(with: properties) { (url, error) in
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

extension RoomCreationViewModel {
    func shareLink() {
        buo.showShareSheet(with: properties,
                           andShareText: "Join my room!\n\(inviteLink.value ?? "")",
                           from: router.owner) { (activityType, completed) in

        }
    }
}
