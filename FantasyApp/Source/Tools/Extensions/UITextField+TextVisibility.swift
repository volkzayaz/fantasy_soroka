//
//  UITextField+TextVisibility.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 08.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

extension UITextField {
    func toggleTextVisibility() {
        isSecureTextEntry.toggle()

        if let existingText = text, isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()

            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }

        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}

