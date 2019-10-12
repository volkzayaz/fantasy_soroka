//
//  GradientLineView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class GradientLineView: UIView {

    public var gradientLayer: CAGradientLayer {

        let layerVar = CAGradientLayer()
        let color1 = UIColor.clear
        let color2 = UIColor.white.withAlphaComponent(0.5)
        let color3 = UIColor.clear

        layerVar.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        layerVar.startPoint = CGPoint(x: 0.0, y: 0.5)
        layerVar.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.insertSublayer(layerVar, at: 0)

        return layerVar
    }

    override public func layoutSubviews() {

        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

}
