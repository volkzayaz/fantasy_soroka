//
//  ProfileSettingsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit
import MessageUI

struct ProfileSettingsRouter : MVVM_Router {
    
    unowned private(set) var owner: ProfileSettingsViewController
    init(owner: ProfileSettingsViewController) {
        self.owner = owner
    }
    
    func dismiss() {
        owner.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showSafari(for url: URL) {
        let vc = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
        owner.present(vc, animated: true, completion: nil)
    }
    
    func showCopyUserIdMessage() {
        
        let alert = UIAlertController(title: R.string.localizable.fantasySettingsCopyUseridAlertSuccess(), message: R.string.localizable.fantasySettingsCopyUseridAlertText(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.generalOk(), style: .cancel, handler: nil))
        
        owner.present(alert, animated: true, completion: nil)
    }
    
    func showMail(for userID: String, appVersion: String, osVersion: String, subject: String) {
        
        let email = R.string.localizable.fantasySettingsReportBugDestinationEmail()
        let message = R.string.localizable.fantasySettingsReportBugText(userID, appVersion, osVersion)
        
        if MFMailComposeViewController.canSendMail() {
            
            let composePicker = MFMailComposeViewController()
            composePicker.mailComposeDelegate = owner
            composePicker.setToRecipients([email])
            composePicker.setSubject(subject)
            composePicker.setMessageBody(message, isHTML: false)
            
            owner.present(composePicker, animated: true, completion: nil)
            
            return
        }
        
        guard let url = URL.emailUrl(to: email, subject: subject, body: message) else {
            print("Can't build email url.")
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Can't open email url.")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func presentFlirtAccess() {
        let x = R.storyboard.userGateway.flirtAccessViewController()!
        x.viewModel = .init(router: .init(owner: x))
        
        let nav = FantasyPinkNavigationController(rootViewController: x)
        nav.modalPresentationStyle = .fullScreen

        owner.present(nav, animated: true, completion: nil)
        
    }
    
}
