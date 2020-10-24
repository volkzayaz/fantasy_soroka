//
//  FlirtAccessRouter.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 5/27/20.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

struct FlirtAccessRouter : MVVM_Router {
    
    unowned private(set) var owner: FlirtAccessViewController
    
    init(owner: FlirtAccessViewController) {
        self.owner = owner
    }
}
