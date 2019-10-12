//
//  GradientView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/10/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class GradientBackgroundView: UIView {

    public var gradientLayer: CAGradientLayer {

        let layerVar = CAGradientLayer()
        let color1 = UIColor(named: "bgGradient1")!
        let color2 = UIColor(named: "bgGradient2")!
        let color3 = UIColor(named: "bgGradient3")!

        layerVar.colors = [color1.cgColor, color2.cgColor, color3.cgColor]

        layer.insertSublayer(layerVar, at: 0)

        return layerVar
    }

    override public func layoutSubviews() {

        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

}
