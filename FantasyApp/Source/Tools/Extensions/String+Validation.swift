//
//  String+Validation.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension String {

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

extension StringProtocol {
    func nsRange(from range: Range<Index>) -> NSRange {
        return .init(range, in: self)
    }
}
