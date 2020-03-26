//
//  CopyableLabel.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.03.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class CopyableLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.copyableInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.copyableInit()
    }

    func copyableInit() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.menu)))
    }

    override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text

        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}

//MARK:- Action

extension CopyableLabel {
    @objc func menu(sender: AnyObject?) {
        self.becomeFirstResponder()

        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}
