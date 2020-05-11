//
//  Localizable.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 5/11/20.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

protocol Localizable {
    var localized: String { get }
}
extension String: Localizable {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
