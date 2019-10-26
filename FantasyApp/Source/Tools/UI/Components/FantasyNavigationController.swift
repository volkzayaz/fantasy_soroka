//
//  FantasyNavigationController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class FantasyNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.applyFantasyStyling()

        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
        setNavigationBarHidden(viewController.prefersNavigationBarHidden, animated: true)
        
    }
    
}

extension UIViewController {
    
    @objc var prefersNavigationBarHidden: Bool {
        return false
    }
    
}

extension UINavigationBar {
    func applyFantasyStyling() {
        backgroundColor = .clear
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
        tintColor = .white
        titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
}
