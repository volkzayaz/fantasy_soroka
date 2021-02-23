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
    
    init(router: InviteSheetRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
        
        self.buo = room.value.shareLine()
    }
}

extension InviteSheetViewModel {
    func copyLinkViewAction() {
        
        buo?.getShortUrl(with: BranchLinkProperties()) { (url, error) in
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            UIPasteboard.general.string = text
        }
        
    }
    
    func SMSViewAction() {
        buo?.getShortUrl(with: BranchLinkProperties()) { (url, error) in
            
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            
            let sms: String = "sms:+1234567890&body=\(text)"
            let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        }
        
    }
    
    func whatsAppViewAction() {
        
        buo?.getShortUrl(with: BranchLinkProperties()) { (url, error) in
            
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            
            if let whatappURL = URL(string: "https://api.whatsapp.com/send?phone=1&text=\(text)"),
              UIApplication.shared.canOpenURL(whatappURL)
            {
                UIApplication.shared.open(whatappURL, options: [:], completionHandler: nil)
            }
            
        }
        
    }
    
    func messengerViewAction() {
        print("Messenger tapped")
    }
    
    func moreViewAction() {
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: R.string.localizable.roomBranchObjectDescription(),
                            from: router.owner) { (activityType, completed) in }
    }
}
