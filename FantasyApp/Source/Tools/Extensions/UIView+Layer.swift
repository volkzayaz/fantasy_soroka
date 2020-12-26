//
//  UIView+Layer.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 26.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            if let borderColor = layer.borderColor {
                return UIColor(cgColor: borderColor)
            } else {
                return .clear
            }
        }
        
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set(newCornerRadius) {
            layer.cornerRadius = newCornerRadius
            clipsToBounds = true
        }
    }
}
