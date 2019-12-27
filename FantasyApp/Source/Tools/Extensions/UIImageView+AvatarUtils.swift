//
//  UIImage+AvatarUtils.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UIImageView {

    func addEllipsMask() {

        let size = bounds.size
        let f = CGRect(x: size.width * 0.75, y: 0, width: size.width, height: size.height )
        let path = UIBezierPath.init()
        path.append(UIBezierPath(rect: CGRect.init(x: 0, y: 0, width: size.width, height: size.height)))
        path.append(UIBezierPath(ovalIn: f))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd

        self.layer.mask = shapeLayer
    }
}
