//
//  ChatRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ChatRouter: MVVM_Router {

    unowned private(set) var owner: ChatViewController
    init(owner: ChatViewController) {
        self.owner = owner
    }
}
