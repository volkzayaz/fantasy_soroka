//
//  DiscoveryFilter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct DiscoveryFilter: Equatable {
    
    let filter: SearchPreferences
    let community: Community

}

struct SearchPreferences: Codable, Equatable {
    var age: Range<Int>
    var gender: Gender
   private var sexuality: Sexuality
    var couple: RelationshipStatus

    static var `default`: SearchPreferences {
        return SearchPreferences(age: 18..<30, gender: .male, sexuality: .all, couple: .single)
    }
}


// MARK:- Migration

extension SearchPreferences {

    var sexualityV2: Sexuality {
        set {
            sexuality = newValue
        }
        get {
            return sexuality == .all ? sexuality : .all
        }
    }

    var toSearchPreferencesV2: SearchPreferences {
        guard sexuality != .all else {
            return self
        }
        return SearchPreferences(age: age, gender: gender, sexuality: .all, couple: couple)
    }
}

