//
//  RoomSettingsViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Branch
import RxDataSources

extension RoomSettingsViewModel {
    
    func securitySettingsViewModelFor(room: Room) -> RoomSettingsPremiumFeatureViewModel {
        
        let isScreenShieldAvailable = User.current?.subscription.isSubscribed ?? false
        let options = [(R.string.localizable.roomSettingsSecurityOptionScreenShield(),
                        room.settings.isScreenShieldEnabled)]
        return RoomSettingsPremiumFeatureViewModel(
            title: R.string.localizable.roomSettingsSecurityTitle(),
            description: R.string.localizable.roomSettingsSecurityDescription(),
            options: options,
            isEnabled: isScreenShieldAvailable
        )
    }
    
}

struct RoomSettingsViewModel: MVVM_ViewModel {

    enum CellModel: IdentifiableType, Equatable {
        case user(
            thumbnailURL: String,
            isAdmin: Bool,
            name: String,
            status: Room.Participant.Status?,
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

    let room: BehaviorRelay<Room>
    
    private let users = BehaviorRelay<[User]>(value: [User.current!])
    

    let inviteLink = BehaviorRelay<String?>(value: nil)
    private let buo: BranchUniversalObject
    private let properties: BranchLinkProperties
    
    var participantsDataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        return users.asDriver().map { users in
            var models = users.map { user in
                return CellModel.user(
                    thumbnailURL: user.bio.photos.avatar.thumbnailURL,
                    isAdmin: self.room.value.ownerId == user.id,
                    name: user.bio.name,
                    status: self.room.value.participants.first(where: { $0.userId == user.id })?.status,
                    identifier: user.id
                )
            }

            // Add placeholder item
            if models.count == 1 { models.append(.invite) }

            return [AnimatableSectionModel(model: "", items: models)]
        }
    }

    init(router: RoomSettingsRouter, room: Room) {
        self.router = router
        self.room = BehaviorRelay(value: room)
        
        self.buo = BranchUniversalObject(canonicalIdentifier: "room/\(room.id)")
        self.properties = BranchLinkProperties()

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)

        generateInviteLink()
        loadParticipants()
    }
    
    let router: RoomSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomSettingsViewModel {
    
    private func generateInviteLink() {
        guard let invitationLink = room.value.participants
            .first(where: { $0.invitationLink != nil })?
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
        Single.zip(room.value.participants.compactMap { $0.userId }.map { UserManager.getUser(id: $0) })
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { users in
                self.users.accept(users.compactMap { $0 })
            })
            .disposed(by: bag)
    }
    
    func shareLink() {
        buo.showShareSheet(with: properties,
                           andShareText: "Join my room!\n\(inviteLink.value ?? "")",
                           from: router.owner) { (activityType, completed) in

        }
    }

    func setIsScreenShieldEnabled(_ isScreenShieldEnabled: Bool) {
        
        var roomSettings = room.value.settings
        
        roomSettings.isScreenShieldEnabled = isScreenShieldEnabled
        
        RoomManager.updateRoomSettings(roomId: room.value.id, settings: roomSettings)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { updatedRoom in
                self.room.accept(updatedRoom)
            })
            .disposed(by: bag)
    }

    func showNotificationSettings() {
        router.showNotificationSettings(for: room.value)
    }
    
    func leaveRoom() {
        //router.owner.navigationController?.popViewController(animated: true)
    }
}
