//
//  UIBarButtonItem+FantasyFont.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension  UIBarButtonItem {
    func applyFantasyAttributes() {
        setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 17.0)
        ], for: .normal)
    }
}
