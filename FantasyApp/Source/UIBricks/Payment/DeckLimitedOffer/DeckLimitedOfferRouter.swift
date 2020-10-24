//
//  DeckLimitedOfferRouter.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 20.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

struct DeckLimitedOfferRouter: MVVM_Router {
    
    unowned let owner: DeckLimitedOfferController
    
    init(owner: DeckLimitedOfferController) {
        self.owner = owner
    }
}
