//
//  UIColor+Style.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UIColor {

    // MARK: - Gradients
    static let gradient1 = UIColor(red: 84, green: 238, blue: 203)
    static let gradient2 = UIColor(red: 184, green: 141, blue: 218)
    static let gradient3 = UIColor(red: 237, green: 61, blue: 138)

    // MARK: - Buttons
    static let shadow = UIColor(red: 199, green: 119, blue: 197)
    static let primary = UIColor.white
    static let primaryDisabled = UIColor.white.withAlphaComponent(0.3)
    static let primaryHighlighted = UIColor.white.withAlphaComponent(0.8)

    // MARK: - Text
    static let title = UIColor.white
    static let fantasyBlack = UIColor(red: 72, green: 78, blue: 94)
    static let basicGrey = UIColor(red: 175, green: 180, blue: 193)
    static let fantasyGrey = UIColor(red: 237, green: 237, blue: 241)
    static let fantasyPink = UIColor(red: 211, green: 100, blue: 177)

    // MARK: - ErrorView
    static let errorViewBackground = UIColor.black.withAlphaComponent(0.1)

    // MARK: - Chat
    static let messageBackground = UIColor(red: 247, green: 247, blue: 250)
    static let myMessageBackground = UIColor(red: 211, green: 100, blue: 177)
}
