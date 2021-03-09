//
//  FantasyDeckRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasyDeckRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyDeckViewController
    init(owner: FantasyDeckViewController) {
        self.owner = owner
    }
    
    func cardTapped(provider: FantasyDetailProvider) {
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), provider: provider)
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = owner
        
        owner.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    func show(collection: Fantasy.Collection, collectionPickedAction: CollectionPicked?) {
        
        let vc = R.storyboard.fantasyCard.fantasyCollectionDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), collection: collection, collectionPickedAction: collectionPickedAction, context: .Collection)
        let container = FantasyNavigationController(rootViewController: vc)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
        
    }

    func showUser(user: UserProfile?) {

        guard let user = unwrap(maybeUser: user, for: owner) else { return }
        
        let vc = R.storyboard.user.userProfileViewController()!
        vc.viewModel = .init(router: .init(owner: vc), user: user, bottomActionsAvailable: false)
        let navigationController = FantasyNavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        owner.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showSubscription() {
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: .accessToAllDecks, purchaseInterestContext: .accessToAllDecks)
        
        owner.present(nav, animated: true, completion: nil)
        
    }

    func showAddCollection(skip: Set<String>, completion: @escaping CollectionPicked) {
        
        let vc = R.storyboard.fantasyCard.fantasiesViewController()!
        vc.viewModel = FantasyDeckViewModel(router: .init(owner: vc),
                                            provider: MainDeckProvider(),
                                            presentationStyle: .modal,
                                            room: nil,
                                            collectionFilter: skip,
                                            collectionPickedAction: { [weak o = owner] (collection) in
                                                
                                                o?.dismiss(animated: true, completion: {
                                                    completion(collection)
                                                })
                                                
                                            })
        let nav = FantasyNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen

        owner.present(nav, animated: true, completion: nil)
        
    }
    
    func showInviteSheet(room: SharedRoomResource) {
        let viewController = R.storyboard.rooms.inviteSheetViewController()!
        let router = InviteSheetRouter(owner: viewController)
        let viewModel = InviteSheetViewModel(router: router, room: room)
        
        viewController.viewModel = viewModel
        
        let container = FantasyNavigationController(rootViewController: viewController)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
    }
    
}
