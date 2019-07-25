//
//  UIFont+Style.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

extension UIFont {
    static func boldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: size)!
    }

    static func regularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: size)!
    }
}
