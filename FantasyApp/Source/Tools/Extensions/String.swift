//
//  String.swift
//
//  Created by Vodolazkyi Anton on 10/11/18.
//

import UIKit
import Foundation

extension String {
    
    func toAttributed(
        with font: UIFont?,
        lineSpacing: CGFloat = 1,
        alignment: NSTextAlignment = .left,
        color: UIColor = .black,
        kern: CGFloat = 0,
        underlineStyle: NSUnderlineStyle = [],
        strikethroughStyle: NSUnderlineStyle? = nil,
        strikethroughColor: UIColor = .clear,
        lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        var attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.kern: kern,
            NSAttributedString.Key.underlineStyle: underlineStyle.rawValue
        ]
        
        if let strikethroughStyle = strikethroughStyle {
            attrs[NSAttributedString.Key.strikethroughStyle] = strikethroughStyle.rawValue
            attrs[NSAttributedString.Key.strikethroughColor] = strikethroughColor
        }
        
        return NSAttributedString(string: self, attributes: attrs)
    }
    
}
