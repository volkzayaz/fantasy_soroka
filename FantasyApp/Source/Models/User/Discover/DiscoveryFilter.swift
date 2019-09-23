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
    
    static var `default`: SearchPreferences {
        return SearchPreferences(age: 18..<30, gender: .male)
    }
}
