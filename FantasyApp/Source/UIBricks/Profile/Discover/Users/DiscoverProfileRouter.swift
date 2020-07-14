//
//  DiscoverProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

struct DiscoverProfileRouter : MVVM_Router {
    
    unowned private(set) var owner: DiscoverProfileViewController
    init(owner: DiscoverProfileViewController) {
        self.owner = owner
    }
    
    func presentProfile(_ profile: Profile) {
    
        let vc = R.storyboard.user.userProfileViewController()!
        vc.viewModel = .init(router: .init(owner: vc), user: profile)
        let navigationController = FantasyNavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        owner.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    func presentFilter() {
        
        let x = R.storyboard.user.discoveryFilterViewController()!
        x.viewModel = .init(router: .init(owner: x))

        let nav = FantasyNavigationController(rootViewController: x)
        nav.modalPresentationStyle = .fullScreen

        owner.present(nav, animated: true, completion: nil)
    }

    func openTeleport() {
        let x = R.storyboard.user.teleportViewController()!
        x.viewModel = .init(router: .init(owner: x), response: .directApplication)
        owner.navigationController?.pushViewController(x, animated: true)
    }


    func invite(_ items: [Any]) {
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: items, applicationActivities: nil)

        activityViewController.popoverPresentationController?.sourceView = owner.view
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        owner.present(activityViewController, animated: true, completion: nil)
    }
    
    func presentSubscriptionLimitedOffer() {
        let vc = R.storyboard.subscription.subscriptionLimitedOfferController()!
        let navigationController = FantasyNavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        vc.viewModel = SubscriptionLimitedOfferViewModel(router: .init(owner: vc))
        owner.present(navigationController, animated: true, completion: nil)
    }
}
