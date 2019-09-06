//
//  ProfilePhotoRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ProfilePhotoRouter : MVVM_Router {
    
    unowned private(set) var owner: EditProfilePhotoCell
    unowned private(set) var container: EditProfileViewController
    init(owner: EditProfilePhotoCell, container: EditProfileViewController) {
        self.owner = owner
        self.container = container
    }
    
    var animatable: ProgressAnimatable {
        return owner
    }
    
    var messagePresentable: MessagePresentable {
        return container
    }
    
}
