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

class TransparentTextField: UITextField {

    let clearButton = UIButton()
    let showPasswordButton = UIButton()

    fileprivate let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        clearButton.setImage(R.image.textFieldClear(), for: .normal)

        showPasswordButton.addTarget(self, action: #selector(showPassword), for: .touchDown)
        showPasswordButton.addTarget(self, action: #selector(hidePassword), for: .touchUpOutside)
        showPasswordButton.setImage(R.image.showPassword(), for: .normal)

        let list =  (isSecureTextEntry == true) ? [showPasswordButton, clearButton] : [clearButton]
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
        text = nil
    }

    @objc func showPassword() {
            isSecureTextEntry = false
        }

    @objc func hidePassword() {
            isSecureTextEntry = true
        }
}


