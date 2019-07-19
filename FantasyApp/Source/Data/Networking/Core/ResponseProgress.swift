//
//  ResponseProgress.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

/// A type representing the progress of a request.
public enum ResponseProgress<T: Decodable> {

    case progress(Progress)
    case value(T)
    
    /// The fraction of the overall work completed by the progress object.
    public var progress: Double {
        switch self {
        case .progress(let p): return p.totalUnitCount > 0 ? p.fractionCompleted : 0
        case .value(_): return 1
        }
    }
     
}
