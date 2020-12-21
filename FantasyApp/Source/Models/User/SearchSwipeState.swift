//
//  SearchSwipeState.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 08.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

struct SearchSwipeState: Decodable {
    
    let ownerId: String
    let amount: Int
    let paidMembership: Bool
    let wouldBeUpdatedAt: Date?
    let type: String
}
