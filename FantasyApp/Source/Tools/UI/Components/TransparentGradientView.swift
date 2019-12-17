//
//  TransparentGradientView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 06.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class TransparentGradientView: UIView {

    @IBInspectable var directionTopToBottom: Bool = false

    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear

        let c1 = UIColor.black.withAlphaComponent(0).cgColor
        let c2 = UIColor.black.withAlphaComponent(0.15).cgColor
        let c3 = UIColor.black.withAlphaComponent(0.3).cgColor
        let c4 = UIColor.black.withAlphaComponent(0.6).cgColor

        var colors = [c1, c2, c3, c4]

        if directionTopToBottom {
            colors.reverse()
        }

        gradientLayer.colors = colors
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.frame = rect
    }
}
