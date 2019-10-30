//
//  UIView+RoundedCorners.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

extension UIView {
   func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
    
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
