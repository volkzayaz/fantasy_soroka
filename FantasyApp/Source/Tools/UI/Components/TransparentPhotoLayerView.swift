//
//  TransparentPhotoLayerView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class TransparentPhotoLayerView: UIView {

    let maskLayer = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0

        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        maskLayer.fillRule = .evenOdd
        maskLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        maskLayer.lineWidth = 1.0

        layer.addSublayer(maskLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskLayer.frame = bounds

        let deltaY = bounds.height/4

        let pathTop = UIBezierPath()
        pathTop.move(to: CGPoint(x: 0.0, y: 0.0))
        pathTop.addLine(to: CGPoint(x: bounds.width, y: 0))
        pathTop.addLine(to: CGPoint(x: bounds.width, y: deltaY))
        pathTop.addQuadCurve(to: CGPoint(x: 0, y: deltaY),
                             controlPoint: CGPoint(x: bounds.width / 2, y: 0))
        pathTop.addLine(to: CGPoint(x:0, y: 0))

        let pathBottom = UIBezierPath()
        pathBottom.move(to: CGPoint(x: 0.0, y: bounds.height))
        pathBottom.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        pathBottom.addLine(to: CGPoint(x: bounds.width, y: bounds.height - deltaY))
        pathBottom.addQuadCurve(to: CGPoint(x: 0, y: bounds.height - deltaY),
                                controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height - (deltaY * 2)))
        pathBottom.addLine(to: CGPoint(x: 0.0, y: bounds.height))

        pathTop.append(pathBottom)
        pathTop.close()

        maskLayer.path = pathTop.cgPath
    }
}
