//
//  FantasyStackView.swift
//  FantasyApp
//
//  Created by Admin on 27.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

@IBDesignable class FantasyStackView: UIStackView {
    @IBInspectable private var color: UIColor?

    private lazy var backgroundLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        layer.insertSublayer(shapeLayer, at: 0)
        return shapeLayer
    }()
    

    override var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(roundedRect: bounds,
                                            byRoundingCorners: [.topLeft, .topRight],
                                            cornerRadii: CGSize(width: 20, height: 20)).cgPath
        backgroundLayer.fillColor = backgroundColor?.cgColor
    }
}
