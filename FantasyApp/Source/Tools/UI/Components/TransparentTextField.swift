//
//  TransparentTextField.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class TransparentTextField: UITextField {

    let clearButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()

        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
//        clearButton.setContentHuggingPriority(.required, for: .horizontal)
//        clearButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        clearButton.setImage(R.image.textFieldClear(), for: .normal)
        rightView = clearButton
        rightViewMode = .whileEditing
        guard let p = placeholder else { return }

        attributedPlaceholder = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.31)])
    }

    @objc func clear() {
        text = nil
//        clearButton.isHidden = true
    }
}


