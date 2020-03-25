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
    
    var securitySettingsViewModel: RoomSettingsPremiumFeatureViewModel {
        
        let isScreenShieldAvailable = User.current?.subscription.isSubscribed ?? false
        let options = [(R.string.localizable.roomSettingsSecurityOptionScreenShield(),
                        room.value.settings.isScreenShieldEnabled)]
        
        return RoomSettingsPremiumFeatureViewModel(
            title: R.string.localizable.roomSettingsSecurityTitle(),
            description: R.string.localizable.roomSettingsSecurityDescription(),
            options: options,
            isEnabled: isScreenShieldAvailable
        )
    }
    
    var participantsDataSource: Driver<[AnimatableSectionModel<String, CellModel>]> {
        
        return cells.asDriver().map { cells in
            
            return [AnimatableSectionModel(model: "",
                                           items: cells)]
            
        }
    }
    
    var intiteLinkHidden: Driver<Bool> {
        return inviteLink.asDriver().map { $0 == nil }
    }
    
    var destructiveButtonTitle: Driver<String?> {
        
        return room.asDriver()
            .map { room in
                
                if room.isDraftRoom {
                    return nil
                }

                return room.ownerId == User.current?.id ?
                    "Delete Room" :
                    "Leave Room"
            }
        
    }
    
    var title: Driver<String> {
        
        return room.asDriver()
            .map { room in
                
                let isNewRoom = room.isDraftRoom
                
                return isNewRoom ? "New Room Settings" : "Room Settings"

            }
        
    }
    
}

struct RoomSettingsViewModel: MVVM_ViewModel {

    private let room: SharedRoomResource
    
    let inviteLink = BehaviorRelay<String?>(value: nil)
    
    private let cells: BehaviorRelay<[CellModel]>
    private let buo: BranchUniversalObject?
    
    init(router: RoomSettingsRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
        
        let maybeLink = room.value.participants.first(where: { participant in
            participant.status == .invited && participant.invitationLink != nil
        })?.invitationLink
        
        if let invitationLink = maybeLink {
        
            self.buo = BranchUniversalObject(canonicalIdentifier: "room/\(room.value.id)")
            buo?.title = "Fantasy"
            buo?.contentDescription = "Hey! We have things to swipe together 🍓Check out Fantasy Match!"
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
        
        cells = BehaviorRelay(value: room.value.participants.enumerated()
                                        .map { (i, x) -> CellModel in
                                            
                                            guard let _ = x.userId else {
                                                return .invite
                                            }
                                            
                                            return .user(isAdmin: x.userId == room.value.ownerId,
                                                         participant: x)
        })
        
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
        
    }
    
    let router: RoomSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
    enum CellModel: IdentifiableType, Equatable {
        case user(isAdmin: Bool, participant: Room.Participant)
        case invite
        case waiting

        var identity: String {
            switch self {
                
            case .user(_, let participant):
                return participant.identity
                
            case .invite: return "invite"
            case .waiting: return "waiting"
                
            }
        }
    }
}

extension RoomSettingsViewModel {

    func shareLink(type: Analytics.Event.DraftRoomShared.Of) {
        
        Analytics.report(Analytics.Event.DraftRoomShared(type: type))
        
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: "Hey! We have things to swipe together 🍓Check out Fantasy Match!",
                            from: router.owner) { (activityType, completed) in

        }
     
        swapToWaiting()
    }
    
    func copyClicked() {
        UIPasteboard.general.string = inviteLink.value
        
        swapToWaiting()
    }
    
    private func swapToWaiting() {
        cells.accept(cells.value.map { x in
            if case .invite = x {
                return .waiting
            }
            
            return x
        })
    }

    func setIsScreenShieldEnabled(_ isScreenShieldEnabled: Bool, turnoff: @escaping () -> Void )  {
        
        guard User.current?.subscription.isSubscribed ?? false else {
            
            return router.owner.showDialog(title: "Club Membership",
                                           text: R.string.localizable.roomSettingsUpgradeSuggestion(),
                                           style: .alert, negativeText: "Subscribe",
                                           negativeCallback: router.showSubscription,
                                           positiveText: "No, thanks", positiveCallback: turnoff)
            
        }
        
        var daRoom = room.value
        
        daRoom.settings.isScreenShieldEnabled = isScreenShieldEnabled
        
        room.accept(daRoom)
     
        Dispatcher.dispatch(action: UpdateRoomSettingsIn(room: daRoom))
        
    }

    func showNotificationSettings() {
        router.showNotificationSettings(for: room.value)
    }
    
    func showParticipant(participant: Room.Participant) {
        
        UserManager.getUser(id: participant.userSlice.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (user) in
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
        
    }
    
    func leaveRoom() {
        
        let r = room.value
        RoomManager.deleteRoom(r.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (_) in
                Dispatcher.dispatch(action: DeleteRoom(room: r))
                self.router.owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
        
    }
}
