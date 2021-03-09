//
//  InviteSheetRouter.swift
//  FantasyApp
//
//  Created by Максим Сорока on 22.02.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation


struct InviteSheetRouter: MVVM_Router {
    unowned private(set) var owner: InviteSheetViewController
    init(owner: InviteSheetViewController) {
        self.owner = owner
    }
    
}
