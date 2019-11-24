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
}
