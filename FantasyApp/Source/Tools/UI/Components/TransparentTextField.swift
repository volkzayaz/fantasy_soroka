//
//  TransparentTextField.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BDTransparentTextField: TransparentTextField {

    func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
}

class TransparentTextField: UITextField {

    let clearButton = UIButton()
    let showPasswordButton = UIButton()
    var isSecureTextEntryVar: Bool = false

    fileprivate let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        isSecureTextEntryVar = isSecureTextEntry

        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        clearButton.setImage(R.image.textFieldClear(), for: .normal)

        showPasswordButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        showPasswordButton.setImage(R.image.showPassword(), for: .normal)
        showPasswordButton.setImage(R.image.hidePassword(), for: .selected)


        let list =  isSecureTextEntryVar ? [showPasswordButton, clearButton] : [clearButton]
        let stack = UIStackView(arrangedSubviews: list)
        stack.spacing = 12.0
        rightView = stack
        rightViewMode = .whileEditing
        guard let p = placeholder else { return }

        attributedPlaceholder = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.31)])

        rx.text.asDriver()
            .map { $0?.count ?? 0 == 0}
            .drive(stack.rx.isHidden)
            .disposed(by: bag)
    }

    @objc func clear() {
        self.text = ""
        showPasswordButton.isSelected = false

        if isSecureTextEntryVar {
            isSecureTextEntry = true
        }
    }

    @objc func showPassword() {
        isSecureTextEntry = showPasswordButton.isSelected
        showPasswordButton.isSelected =  !showPasswordButton.isSelected
    }
}


