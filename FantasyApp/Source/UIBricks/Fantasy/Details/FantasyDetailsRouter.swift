//
//  FantasyDetailsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasyDetailsRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyDetailsViewController
    init(owner: FantasyDetailsViewController) {
        self.owner = owner
    }

    func close() {
        owner.dismiss(animated: true, completion: nil)
    }
    
    func show(collection: Fantasy.Collection) {
        
        let vc = R.storyboard.fantasyCard.fantasyCollectionDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), collection: collection)
        let container = FantasyNavigationController(rootViewController: vc)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
        
    }
    
}
