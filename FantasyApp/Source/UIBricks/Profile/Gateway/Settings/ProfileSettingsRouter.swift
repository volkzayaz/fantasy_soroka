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

}
