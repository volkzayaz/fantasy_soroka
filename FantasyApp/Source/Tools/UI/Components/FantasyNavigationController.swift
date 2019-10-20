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

        navigationBar.backgroundColor = .clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
