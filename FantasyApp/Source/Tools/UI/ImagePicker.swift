//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import FDTake

protocol ImagePicker {
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void)
}

enum FDTakeImagePicker: ImagePicker {
    
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void) {
        
        let x = FDTakeController()
        x.allowsVideo = false
        x.didGetPhoto = { image, _ in
            completion(image)
        }
        x.allowsEditing = true
        x.presentingViewController = viewController
        
        x.present()
    }
    
}
