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

    func addFantasyTripleGradient() {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds

        let color1 = UIColor(named: "bgGradient1")!
        let color2 = UIColor(named: "bgGradient2")!
        let color3 = UIColor(named: "bgGradient3")!

        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addFantasySubscriptionGradient(radius: Bool = false) {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds

        let color1 = UIColor(fromHex: 0xF0398B)
        let color2 = UIColor(fromHex: 0xB77AE9)
        let color3 = UIColor(fromHex: 0x54EECB)

        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        gradientLayer.locations = [0, 0.6, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.4)
        
        if radius {
            gradientLayer.cornerRadius = 8
        }
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addFantasyDiagonalGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        let color1 = UIColor(fromHex: 0xD855B3)
        let color2 = UIColor(fromHex: 0xB281E7)
        let color3 = UIColor(fromHex: 0x7CBFD7)

        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addBlueFantasyDiagonalGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        let color1 = UIColor(fromHex: 0xA392E3)
        let color2 = UIColor(fromHex: 0x60E0CF)

        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func removeGradient() {
        layer.sublayers?.first(where: { $0 is CAGradientLayer })?.removeFromSuperlayer()
    }

    func addFantasyRoundedCorners() {
        clipsToBounds = true
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

}