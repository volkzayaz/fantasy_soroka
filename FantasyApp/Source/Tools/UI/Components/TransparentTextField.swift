//
//  TransparentTextField.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class TransparentTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()

        clearButtonMode = .whileEditing

        guard let p = placeholder else { return }

        attributedPlaceholder = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.31)])
    }

}
