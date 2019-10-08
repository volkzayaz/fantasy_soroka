//
//  MyFantasiesRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

struct MyFantasiesRouter : MVVM_Router {
    
    unowned private(set) var owner: MyFantasiesViewController
    init(owner: MyFantasiesViewController) {
        self.owner = owner
    }
    
    
}
