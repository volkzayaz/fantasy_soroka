//
//  DiscoveryFilter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct DiscoveryFilter {
    let age: Range<Int>
    let radius: CLLocationDistance
    let gender: Gender
}
