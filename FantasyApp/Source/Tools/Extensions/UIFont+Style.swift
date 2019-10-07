//
//  UIFont+Style.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

extension UIFont {
    static func semiBoldFont(ofSize size: CGFloat) -> UIFont {
        return R.font.sfProTextSemibold(size: size)!
    }

    static func boldFont(ofSize size: CGFloat) -> UIFont {
        return R.font.sfProTextBold(size: size)!
    }

    static func regularFont(ofSize size: CGFloat) -> UIFont {
        return R.font.sfProTextRegular(size: size)!
    }

    static func mediumFont(ofSize size: CGFloat) -> UIFont {
        return R.font.sfProTextMedium(size: size)!
    }
}
