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
    
    var participantsDataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        
        return room.asDriver().map { room in
            
            return [AnimatableSectionModel(model: "",
                                           items: room.participants.enumerated()
                                            .map { (i, x) -> CellModel in
                                                
                                                guard let _ = x.userId else {
                                                    return .invite
                                                }
                                                
                                                return .user(isAdmin: i == 0, participant: x)
            })]
            
        }
    }
    
    var intiteLinkShow: Driver<Void> {
        return inviteLink.skip(1)
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .map { _ in }
    }
    
}

struct RoomSettingsViewModel: MVVM_ViewModel {

    enum CellModel: IdentifiableType, Equatable {
        case user(isAdmin: Bool, participant: Room.Participant)
        case invite

        var identity: String {
            switch self {
                
            case .user(_, let participant):
                return participant.identity
                
            case .invite: return "invite"
                
            }
        }
    }

    let room: BehaviorRelay<Room>
    
    let inviteLink = BehaviorRelay<String?>(value: nil)
    
    private let buo: BranchUniversalObject?
    
    
    init(router: RoomSettingsRouter, room: Room) {
        self.router = router
        self.room = BehaviorRelay(value: room)
        
        if let invitationLink = room.participants.first(where: { $0.invitationLink != nil })?.invitationLink {
        
            self.buo = BranchUniversalObject(canonicalIdentifier: "room/\(room.id)")
            buo?.title = "Fantasy"
            buo?.contentDescription = "Join my room!"
            buo?.publiclyIndex = true
            buo?.locallyIndex = true
            buo?.contentMetadata.customMetadata["inviteToken"] = invitationLink
            buo?.getShortUrl(with: BranchLinkProperties()) { [unowned i = inviteLink] (url, error) in
                i.accept(url)
            }
            
        }
        else {
            buo = nil
        }
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
        
    }
    
    let router: RoomSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomSettingsViewModel {

    func shareLink() {
        
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: "Join my room!",
                            from: router.owner) { (activityType, completed) in

        }
        
    }

    func setIsScreenShieldEnabled(_ isScreenShieldEnabled: Bool) {
        
        var roomSettings = room.value.settings
        
        roomSettings.isScreenShieldEnabled = isScreenShieldEnabled
        
        RoomManager.updateRoomSettings(roomId: room.value.id, settings: roomSettings)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .bind(to: room)
            .disposed(by: bag)
    }

    func showNotificationSettings() {
        router.showNotificationSettings(for: room.value)
    }
    
    func leaveRoom() {
        
        RoomManager.deleteRoom(room.value.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (_) in
                self.router.owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
        
    }
}
