//
//  MainTabBarRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct MainTabBarRouter : MVVM_Router {
    
    unowned private(set) var owner: UITabBarController
    init(owner: UITabBarController) {
        self.owner = owner
    }
    
    func presentRoom(room: Room, page: RoomDetailsViewModel.DetailsPage) {
        
        owner.selectedIndex = 3
        let notificationController = (owner.viewControllers![3] as! UINavigationController).viewControllers.first! as! ConnectionViewController
        notificationController.viewModel.router.show(room: room, page: page)
        
    }
    
    func presentCardDetails(card: Fantasy.Card, preferencesEnabled: Bool) {
        
        owner.selectedIndex = 0
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             provider: OwnFantasyDetailsProvider(card: card,
                                                                 initialReaction: .neutral,
                                                                 navigationContext: .ShareLink,
                                                                 preferenceEnabled: preferencesEnabled))
        vc.modalPresentationStyle = .overFullScreen
        
        let p = (owner.viewControllers![0] as! UINavigationController).viewControllers.first!
        p.dismiss(animated: true) { [weak p = p] in
            p?.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func presentCardDetails(card: Fantasy.Card, in room: RoomIdentifier) {
        
        owner.selectedIndex = 1
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             provider: RoomFantasyDetailsProvider(room: room,
                                                                  card: card,
                                                                  initialReaction: .neutral,
                                                                  navigationContext: .ShareLink))
        vc.modalPresentationStyle = .overFullScreen
        
        let p = (owner.viewControllers![0] as! UINavigationController).viewControllers.first!
        p.dismiss(animated: true) { [weak p = p] in
            p?.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func present(collection: Fantasy.Collection) {
        
        owner.selectedIndex = 0
        
        let vc = R.storyboard.fantasyCard.fantasyCollectionDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             collection: collection,
                             context: .Card(.ShareLink))
        vc.modalPresentationStyle = .overFullScreen
        
        (owner.viewControllers![0] as! UINavigationController).viewControllers.first!.present(vc, animated: true, completion: nil)
        
    }
    
}
