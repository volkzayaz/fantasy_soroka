//
//  FantasyError.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum FantasyError: Error {
    
    case generic(description: String)
    case apiError(GenericAPIError)
    case canceled
    case unauthorized
    
}
