//
//  TransparentGradientView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 13.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class TransparentGradientView: UIView {

    public var gradientLayer: CAGradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.0);
        gradientLayer.endPoint = CGPoint(x: 0.5,y: 1.0);
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.9), UIColor.white.withAlphaComponent(0.3), UIColor.white.withAlphaComponent(0.0)]

        layer.addSublayer(gradientLayer)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

}
