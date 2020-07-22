//
//  FantasyCollectionDetailsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/30/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import SafariServices

struct FantasyCollectionDetailsRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyCollectionDetailsViewController
    init(owner: FantasyCollectionDetailsViewController) {
        self.owner = owner
    }
    
    func showSafari(for url: URL) {
        let vc = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
        owner.present(vc, animated: true, completion: nil)
    }
    
    func showCollection(collection: Fantasy.Collection) {
        
        let vc = R.storyboard.fantasyCard.fantasyListViewController()!
        let nav = FantasyPinkNavigationController(rootViewController: vc)
        vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                            cardsProvider:
            Fantasy.Manager.fetchCollectionsCards(collection: collection).asDriver(onErrorJustReturn: []),
                                            detailsProvider: { card in
                                                OwnFantasyDetailsProvider(card: card,
                                                                          initialReaction: .neutral,
                                                                          navigationContext: .CollectionDetails,
                                                                          preferenceEnabled: false)
        })
        
        vc.title = R.string.localizable.fantasyDeckDetailsTitle()
        nav.modalPresentationStyle = .overFullScreen
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back(), style: .done, target: nav, action: "dismiss")
        
        owner.present(nav, animated: true, completion: nil)
    }
    
    func presentDeckLimitedOffer(
        offerType: DeckLimitedOfferViewModel.OfferType,
        collection: Fantasy.Collection,
        deckOffer: CollectionOffer.Offer
    ) {
        let vc = R.storyboard.subscription.deckLimitedOfferController()!
        let navigationController = FantasyNavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        vc.viewModel = DeckLimitedOfferViewModel(
            router: .init(owner: vc),
            offerType: offerType,
            collection: collection,
            deckOffer: deckOffer
        )
        owner.present(navigationController, animated: true, completion: nil)
    }
}
