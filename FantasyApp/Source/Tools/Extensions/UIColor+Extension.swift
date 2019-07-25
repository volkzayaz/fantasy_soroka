//
//  UIColor+Extentions.swift
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1, "Invalid alpha component")

        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }

    func lighter(by percentage: CGFloat = 5.0) -> UIColor {
        return adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 5.0) -> UIColor {
        return adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 5.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return .clear
        }
        return UIColor(red: min(red + percentage / 100, 1.0),
                       green: min(green + percentage / 100, 1.0),
                       blue: min(blue + percentage / 100, 1.0),
                       alpha: alpha)
    }
}
