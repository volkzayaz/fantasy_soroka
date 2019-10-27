//
//  UILabel+Truncation.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 27.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UILabel {

    var isTruncated: Bool {
        guard let text = text, let font = font else {
            return false
        }

        let textSize = (text as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        ).size

        return textSize.height > bounds.size.height
    }
}
