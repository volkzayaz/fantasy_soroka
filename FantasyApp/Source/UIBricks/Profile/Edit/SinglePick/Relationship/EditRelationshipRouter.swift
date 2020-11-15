//
//  EditRelationshipRouter.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 14.11.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

struct EditRelationshipRouter: MVVM_Router {
    
    unowned private(set) var owner: EditRelationshipViewController
    init(owner: EditRelationshipViewController) {
        self.owner = owner
    }
    
    func popBack() {
        owner.navigationController?.popViewController(animated: true)
    }
}
