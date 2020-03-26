//
//  User+Migration.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 25.03.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

enum GenderLegacy: String, CaseIterable, Equatable, Codable {

    case transgenderMale = "MtF"
    case male
    case female
    case transgenderFemale = "FtM"
    case nonBinary

    var toGenderV2: Gender {
        switch self {
        case .male:
            return Gender.male
        case .female:
            return Gender.female
        case .nonBinary, .transgenderMale, . transgenderFemale:
            return Gender.nonBinary
        }
    }
}
