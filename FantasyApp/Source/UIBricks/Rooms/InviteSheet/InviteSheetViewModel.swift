//
//  InviteSheetViewModel.swift
//  FantasyApp
//
//  Created by Максим Сорока on 22.02.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

class InviteSheetViewModel: MVVM_ViewModel {
    private let room: SharedRoomResource
    let router: InviteSheetRouter
    var cancelPressed: BehaviorRelay<Bool> = .init(value: false)
    
    init(router: InviteSheetRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
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
        print("More tapped")
    }
}
