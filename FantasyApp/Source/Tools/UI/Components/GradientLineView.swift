//
//  GradientLineView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class GradientLineView: UIView {

    public var gradientLayer: CAGradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color1 = UIColor.clear
        let color2 = UIColor.white.withAlphaComponent(0.5)
        let color3 = UIColor.clear

        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    override public func layoutSubviews() {

        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

}
