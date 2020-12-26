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
    
    var globalMode: Bool?
    var age: Range<Int>
    var gender: Gender
    private var sexuality: Sexuality

    static var `default`: SearchPreferences {
        return SearchPreferences(globalMode: false, age: 21..<69, gender: .male, sexuality: .all)
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
}

