//
//  RoomSettingsViewModel.swift
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

struct RoomSettingsViewModel: MVVM_ViewModel {

    enum CellModel: IdentifiableType, Equatable {
        case user(
            thumbnailURL: String,
            isAdmin: Bool,
            name: String,
            status: Chat.RoomParticipantStatus?,
            identifier: String)
        case invite

        var identity: String {
            switch self {
            case .user(_, _, _, _, let identifier):
                return identifier
            default:
                return UUID().uuidString
            }
        }
    }

    let router: RoomSettingsRouter
    let room: Chat.Room
    let inviteLink = BehaviorRelay<String?>(value: nil)
    private let buo: BranchUniversalObject
    private let properties: BranchLinkProperties
    private let users = BehaviorRelay<[User]>(value: [User.current!])
    fileprivate let indicator: ViewIndicator = ViewIndicator()

    var participantsDataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        return users.asDriver().map { users in
            var models = users.map { user in
                return CellModel.user(
                    thumbnailURL: user.bio.photos.avatar.thumbnailURL,
                    isAdmin: self.room.ownerId == user.id,
                    name: user.bio.name,
                    status: self.room.participants.first(where: { $0.userId == user.id })?.status,
                    identifier: user.id
                )
            }

            // Add placeholder item
            if models.count == 1 { models.append(.invite) }

            return [AnimatableSectionModel(model: "", items: models)]
        }
    }

    var securitySettingsViewModel: RoomSettingsPremiumFeatureViewModel {
        let isScreenShieldAvailable = User.current?.subscription.isSubscribed ?? false
        let options = [(R.string.localizable.roomSettingsSecurityOptionScreenShield(),
                        isScreenShieldAvailable ? true : false)]

        return RoomSettingsPremiumFeatureViewModel(
            title: R.string.localizable.roomSettingsSecurityTitle(),
            description: R.string.localizable.roomSettingsSecurityDescription(),
            options: options,
            isEnabled: isScreenShieldAvailable
        )
    }

    init(router: RoomSettingsRouter, room: Chat.Room) {
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
        guard let invitationLink = room.participants.first(where: { $0.userId != User.current?.id })?
            .invitationLink else {
            return
        }
        buo.title = "Fantasy"
        buo.contentDescription = "Join my room!"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["invitationLink"] = invitationLink
        properties.addControlParam("invitationLink", withValue: invitationLink)

        buo.getShortUrl(with: properties) { (url, error) in
            self.inviteLink.accept(url)
        }
    }

    private func loadParticipants() {
        Single.zip(room.participants.compactMap { $0.userId }.map { UserManager.getUser(id: $0) })
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { users in
                self.users.accept(users.compactMap { $0 })
            })
            .disposed(by: bag)
    }

    fileprivate let bag = DisposeBag()
}

extension RoomSettingsViewModel {
    func shareLink() {
        buo.showShareSheet(with: properties,
                           andShareText: "Join my room!\n\(inviteLink.value ?? "")",
                           from: router.owner) { (activityType, completed) in

        }
    }

    func setIsScreenShieldEnabled(_ isScreenShieldEnabled: Bool) {
        guard var roomSettings = room.settings else {
            return
        }
        roomSettings.isScreenShieldEnabled = isScreenShieldEnabled
        ChatManager.updateRoomSettings(roomId: room.id, settings: roomSettings)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in })
            .disposed(by: bag)
        
    }
}
