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
import MessageUI

class InviteSheetViewModel: NSObject, MVVM_ViewModel, UINavigationControllerDelegate {
    private let room: SharedRoomResource
    private let buo: BranchUniversalObject?
    let router: InviteSheetRouter
    var cancelPressed: BehaviorRelay<Bool> = .init(value: false)
    
    let flashCopied: PublishRelay<Void> = .init()
    
    init(router: InviteSheetRouter, room: SharedRoomResource) {
        self.router = router
        self.room = room
        
        self.buo = room.value.shareLine()
    }
}

extension InviteSheetViewModel: MFMessageComposeViewControllerDelegate {
    func copyLinkViewAction() {
        
        flashCopied.accept(())
        
        buo?.getShortUrl(with: BranchLinkProperties()) { (url, error) in
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            UIPasteboard.general.string = text
        }
        
    }
    
    func SMSViewAction() {
        buo?.getShortUrl(with: BranchLinkProperties()) { (url, error) in
        
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            
            let controller = MFMessageComposeViewController()
            controller.body = text
            controller.messageComposeDelegate = self
            
            self.router.owner.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    func whatsAppViewAction() {
        
        buo?.getShortUrl(with: BranchLinkProperties()) { [weak r = cancelPressed] (url, error) in
            
            let text = R.string.localizable.roomBranchObjectDescription() + url!
            
            let url = URL(string: "whatsapp://send?text=\(text)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                r?.accept(true)
            })
            
        }
        
    }
    
    func moreViewAction() {
        buo?.showShareSheet(with: BranchLinkProperties(),
                            andShareText: R.string.localizable.roomBranchObjectDescription(),
                            from: router.owner) { [weak r = cancelPressed] (activityType, completed) in
            r?.accept(true)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: { [weak r = cancelPressed] in r?.accept(true) })
    }
    
}
