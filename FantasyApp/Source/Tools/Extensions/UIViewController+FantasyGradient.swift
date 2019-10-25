//
//  UIViewController+FantasyGradient.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UIView {
    func addFantasyGradient(roundCorners: Bool = false) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.gradient2.cgColor, UIColor.gradient3.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        if roundCorners {
            gradientLayer.cornerRadius = bounds.height / 2
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
