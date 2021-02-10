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
    
    var deckDataSource: Driver<[DeckCellModel]> {
        
        return room.distinctUntilChanged { $0.settings.sharedCollections }
            .flatMapLatest { room -> Single<[DeckCellModel]> in
                
                guard room.settings.sharedCollections.count > 0 else { return .just([]) }
                    
                return RoomsSharedCollectionsResource(room: room).rx.request
                    .map { $0.settings.sharedCollectionsData.map(DeckCellModel.deck) }
                
            }
            .map { [.add] + $0 }
            .asDriver(onErrorJustReturn: [])
        
    }
    
    var intiteLinkHidden: Driver<Bool> {
        return inviteLink.asDriver().map { $0 == nil }
    }
    
    var isEmptyRoom: Driver<Bool> {
        return room.asDriver()
        .map { $0.status == .empty }
    }
    
    var destructiveButtonTitle: Driver<String?> {
        
        return room.asDriver()
            .map { room in
                
                if room.status != .ready {
                    return nil
                }

                return room.ownerId == User.current?.id ?
                    R.string.localizable.roomSettingsDelete() :
                    R.string.localizable.roomSettingsLeave()
            }
        
    }
    
    var title: Driver<String> {
        
        return room.asDriver()
            .map { room in
                
                let isNewRoom = room.status != .ready
                
                return isNewRoom ?
                    R.string.localizable.roomsAddNewRoom() :
                    R.string.localizable.roomSettingsRoomSettings()
            }
        
    }
    
}

class RoomSettingsViewModel: MVVM_ViewModel {

    private let room: SharedRoomResource
    
    let inviteLink = BehaviorRelay<String?>(value: nil)
    
    private let cells: BehaviorRelay<[CellModel]>
    private let buo: BranchUniversalObject?
    
    init(router: RoomSettingsRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
        
        self.buo = room.value.shareLine()
        buo?.getShortUrl(with: BranchLinkProperties()) { [unowned i = inviteLink] (url, error) in
            i.accept(url)
        }
        
        cells = BehaviorRelay(value: room.value.participants.enumerated()
                                .map { (i, x) -> CellModel in
                                    
                                    guard let userSlice = x.userSlice else {
                                        return .invite
                                    }
                                    
                                    return .user(isAdmin: userSlice.id == room.value.ownerId,
                                                 participant: userSlice,
                                                 status: x.status)
                                    
                                })
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }
    
    let router: RoomSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
    enum CellModel: IdentifiableType, Equatable {
        case user(isAdmin: Bool, participant: Room.Participant.UserSlice, status: Room.Participant.Status)
        case invite
        case waiting
        
        var identity: String {
            switch self {
            
            case .user(_, let participant, _):
                return participant.identity
                
            case .invite: return "invite"
            case .waiting: return "waiting"
                
            }
        }
    }
    
    enum DeckCellModel: Equatable {
        
        case add
        case deck(Fantasy.Collection)
       
    }
}

extension RoomSettingsViewModel {

    func shareLink(type: Analytics.Event.DraftRoomShared.Of) {
        
        Analytics.report(Analytics.Event.DraftRoomShared(type: type))
        
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: R.string.localizable.roomBranchObjectDescription(),
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
            
            return router.owner.showDialog(
                title: R.string.localizable.roomUpgradeSuggestionTitle(),
                text: R.string.localizable.roomSettingsUpgradeSuggestion(),
                style: .alert,
                negativeText: R.string.localizable.roomUpgradeSuggestionNegativeText(),
                negativeCallback: router.showSubscription,
                positiveText: R.string.localizable.roomUpgradeSuggestionPositiveText(),
                positiveCallback: turnoff)
            
        }
        
        var daRoom = room.value
        
        daRoom.settings.isScreenShieldEnabled = isScreenShieldEnabled
        
        room.accept(daRoom)
     
        Dispatcher.dispatch(action: UpdateRoomSettingsIn(room: daRoom))
        
    }

    func showNotificationSettings() {
        router.showNotificationSettings(for: room.value)
    }
    
    func showParticipant(participant: Room.Participant.UserSlice) {
        
        UserManager.getUserProfile(id: participant.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] (user) in
                
                self.router.showUser(user: user)
            })
            .disposed(by: bag)
        
    }
    
    func leaveRoom() {
        
        let r = room.value
        RoomManager.deleteRoom(r.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] (_) in
                Dispatcher.dispatch(action: DeleteRoom(room: r))
                self.router.owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
        
    }
    
    func addCollection() {
        
        router.showAddCollection(skip: Set(room.value.settings.sharedCollections)) { [unowned self, unowned r = room] (collection) in
            
            var x = r.value
            x.settings.sharedCollections.insert(collection.id, at: 0)
            
            RoomManager.updateRoomSharedCollections(room: x)
                .silentCatch(handler: self.router.owner)
                .trackView(viewIndicator: self.indicator)
                .subscribe(onNext: { room in
                    r.accept(room)
                    Dispatcher.dispatch(action: UpdateRoom(room: room))
                })
                .disposed(by: bag)
            
        }
        
    }
    
    func remove(collection: Fantasy.Collection) {
        var x = room.value
        x.settings.sharedCollections.removeAll { $0 == collection.id }
        
        RoomManager.updateRoomSharedCollections(room: x)
            .silentCatch(handler: self.router.owner)
            .trackView(viewIndicator: self.indicator)
            .subscribe(onNext: { [unowned r = room] room in
                r.accept(room)
                Dispatcher.dispatch(action: UpdateRoom(room: room))
            })
            .disposed(by: bag)
        
    }
    
    func deckOptionsPressed(collection: Fantasy.Collection) {
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (action: UIAlertAction) in
            self.remove(collection: collection)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        router.owner.showDialog(title: nil, text: nil, style: .actionSheet, actions: [deleteAction, cancelAction])
    }
}

