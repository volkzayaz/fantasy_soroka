//
//  UserGatewayRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import ZendeskSDK
import ZendeskCoreSDK
import ZendeskProviderSDK

struct UserGatewayRouter : MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }
    
    func presentTeleport() {
        
        let x = R.storyboard.user.teleportViewController()!
        x.viewModel = .init(router: .init(owner: x), response: .directApplication)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }

    func presentHelp() {

        let helpCenterUiConfig = HelpCenterUiConfiguration()
        helpCenterUiConfig.showContactOptionsOnEmptySearch = false
        helpCenterUiConfig.showContactOptions = false

        let vc = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [helpCenterUiConfig])

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.tintColor = .fantasyPink
        nav.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.fantasyPink
        ]

        owner.present(nav, animated: true, completion: nil)
    }
    
}
