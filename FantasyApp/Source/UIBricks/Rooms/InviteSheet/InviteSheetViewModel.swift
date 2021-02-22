//
//  InviteSheetViewModel.swift
//  FantasyApp
//
//  Created by Максим Сорока on 22.02.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa
import Branch

class InviteSheetViewModel: MVVM_ViewModel {
    private let room: SharedRoomResource
    private let buo: BranchUniversalObject?
    let router: InviteSheetRouter
    var cancelPressed: BehaviorRelay<Bool> = .init(value: false)
    
    var fantasyDeckViewModel: FantasyDeckViewModel? = nil
    var roomDetailsViewModel: RoomDetailsViewModel? = nil
    
    init(router: InviteSheetRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
        
        self.buo = room.value.shareLine()
    }
}

extension InviteSheetViewModel {
    func copyLinkViewAction() {
        print("Copy link tapped")
    }
    
    func SMSViewAction() {
        print("SMS tapped")
    }
    
    func whatsAppViewAction() {
        print("WhatsApp tapped")
    }
    
    func messengerViewAction() {
        print("Messenger tapped")
    }
    
    func moreViewAction() {
        Analytics.report(Analytics.Event.DraftRoomShared(type: .add))
        
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: R.string.localizable.roomBranchObjectDescription(),
                            from: router.owner) { (activityType, completed) in }
    }
}
