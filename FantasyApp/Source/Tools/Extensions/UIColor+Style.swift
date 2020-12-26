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

    static let gradient4 = UIColor(red: 212, green: 91, blue: 181)
    static let gradient5 = UIColor(red: 132, green: 185, blue: 215)

    // MARK: - Fantasy Cards
    static let fantasyCardBackground = UIColor(red: 16, green: 15, blue: 25)
    static let preferenceButtonSelected = UIColor(red: 251, green: 238, blue: 247)

    // MARK: - Buttons
    static let shadow = UIColor(red: 199, green: 119, blue: 197)
    static let primary = UIColor.white
    static let primaryDisabled = UIColor.white.withAlphaComponent(0.3)
    static let primaryHighlighted = UIColor.white.withAlphaComponent(0.8)

    // MARK: - Text
    static let title = UIColor.white
    static let fantasyBlack = UIColor(fromHex: 0x484E5E)
    static let basicGrey = UIColor(red: 175, green: 180, blue: 193)
    static let fantasyLightGrey = UIColor(red: 247, green: 247, blue: 250)
    static let fantasyGrey = UIColor(red: 237, green: 237, blue: 241)
    static let fantasyPink = UIColor(red: 211, green: 100, blue: 177)
    static let fantasyRed = UIColor(red: 255, green: 79, blue: 79)

    // MARK: - ErrorView
    static let errorViewBackground = UIColor.black.withAlphaComponent(0.1)

    // MARK: - General
    static let premium = UIColor(red: 244, green: 198, blue: 127)
    static let fantasySeparator = UIColor(red: 175, green: 180, blue: 193).withAlphaComponent(0.18)

    // MARK: - Chat
    static let messageBackground = UIColor(red: 247, green: 247, blue: 250)
    static let myMessageBackground = UIColor(red: 211, green: 100, blue: 177)
    static let participantAccepted = UIColor(red: 2, green: 212, blue: 185)
    static let participantRejected = UIColor(red: 255, green: 82, blue: 115)
    static let participantInvited = UIColor(red: 175, green: 180, blue: 193)
}
