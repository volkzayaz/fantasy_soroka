//
//  UIViewController+FantasyGradient.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UIView {
    func addFantasyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.gradient3.cgColor,
                                UIColor.gradient2.cgColor,
                                UIColor.gradient1.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
