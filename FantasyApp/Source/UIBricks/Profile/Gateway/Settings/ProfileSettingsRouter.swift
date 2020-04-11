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

import ZendeskSDK
import ZendeskCoreSDK
import ZendeskProviderSDK

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

    func showSupport(for username: String, email: String?) {

        let ident = Identity.createAnonymous(name: username, email: email)
        Zendesk.instance?.setIdentity(ident)
        SupportUI.instance?.helpCenterLocaleOverride = Locale.autoupdatingCurrent.languageCode

        var requestConfig: RequestUiConfiguration {
            let config = RequestUiConfiguration()
            config.subject = "Help iOS App"
            config.tags = ["ios"]
            return config
        }

        let nav = UINavigationController(rootViewController: RequestUi.buildRequestList(with: [requestConfig]))
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.tintColor = .fantasyPink
        nav.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.fantasyPink
        ]

        owner.present(nav, animated: true, completion: nil)
    }

    func showCopyUserIdMessage() {

        let alert = UIAlertController(title: "Information!", message: "Your user id copied.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.generalOk(), style: .cancel, handler: nil))

        owner.present(alert, animated: true, completion: nil)
    }

    func showMail(for userID: String, appVersion: String, osVersion:String) {

        let email = "feedback@fantasyapp.com"
        let subject = "Fantasy Match — Feedback — Bug Report"
        let message = "User ID - \(userID)\n\(appVersion)\niOS version - \(osVersion)"

        guard MFMailComposeViewController.canSendMail() else { return }

        let composePicker = MFMailComposeViewController()
        composePicker.mailComposeDelegate = owner
        composePicker.setToRecipients([email])
        composePicker.setSubject(subject)
        composePicker.setMessageBody(message, isHTML: false)

        owner.present(composePicker, animated: true, completion: nil)
    }

}
