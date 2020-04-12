//
//  UITextView+Truncated.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 11.04.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

extension UITextView {

    var isTextTruncated: Bool {

        var isTruncating = false

        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: Int.max)) { _, _, _, glyphRange, stop in
            let range = self.layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: glyphRange.lowerBound)
            if range.location != NSNotFound {
                isTruncating = true
                stop.pointee = true
            }
        }

        if isTruncating == false {
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

            isTruncating = characterRange.upperBound < text.utf16.count
        }

        return isTruncating
    }
}
