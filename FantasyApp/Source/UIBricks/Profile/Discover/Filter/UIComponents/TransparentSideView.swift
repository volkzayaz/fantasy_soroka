//
//  TransparentSideView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 27.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class TransparentSideView: UIView {

    @IBInspectable open dynamic var direction: Int = 0
    @IBInspectable open dynamic var isVertical: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let gradientLayer = CAGradientLayer()

        if isVertical {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        if direction == 0 {
            gradientLayer.colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.05).cgColor,
            ]

        } else {
            gradientLayer.colors = [
                UIColor.white.withAlphaComponent(0.05).cgColor,
                UIColor.white.cgColor
            ]
        }

        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = rect
    }
}
