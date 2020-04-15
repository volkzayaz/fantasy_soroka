//
//  BlockedViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 15.04.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class BlockedViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var roundedView: UIView! {
        didSet {
            roundedView.addFantasyRoundedCorners()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "Your profile has been blocked for the activity that violates our @Terms@ and @Rules@"
        
        textView
            .replace(placeholder: "@Terms@", with: "Terms and Conditions", url: R.string.localizable.fantasyConstantsTermsUrl())
        
        textView.replace(placeholder: "@Rules@", with: "Community Rules", url: R.string.localizable.fantasyConstantsCommunityRulesUrl())
    }
}

extension UITextView {
    
    func replace(placeholder: String, with hyperlink: String, url: String) {
        let mutableAttr = NSMutableAttributedString(attributedString: self.attributedText)

        let hyperlinkAttr = NSAttributedString(string: hyperlink, attributes: [
            .link: URL(string: url)!,
            .font: self.font!,
            .foregroundColor: self.textColor!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: self.textColor!
        ])

        tintColor = textColor
        
        let placeholderRange = (self.attributedText!.string as NSString).range(of: placeholder)

        mutableAttr.replaceCharacters(in: placeholderRange, with: hyperlinkAttr)
        
        attributedText = mutableAttr
    }
}
