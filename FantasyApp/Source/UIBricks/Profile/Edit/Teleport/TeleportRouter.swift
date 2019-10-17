//
//  TeleportRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct TeleportRouter : MVVM_Router {
    
    unowned let owner: TeleportViewController
    init(owner: TeleportViewController) {
        self.owner = owner
    }
    
    func popBack() {
        
        owner.navigationController?.popViewController(animated: true)
        
    }
    
}
