//
//  ResponseProgress.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

/// A type representing the progress of a request.
public struct ResponseProgress<T: Decodable> {

    /// The optional response of the request.
    public let response: T?

    /// An object that conveys ongoing progress for a given request.
    public let progressObject: Progress?

    /// Initializes a `ProgressResponse`.
    public init(progress: Progress? = nil, response: T? = nil) {
        self.progressObject = progress
        self.response = response
    }

    /// The fraction of the overall work completed by the progress object.
    public var progress: Double {
        if completed {
            return 1.0
        } else if let progressObject = progressObject, progressObject.totalUnitCount > 0 {
            // if the Content-Length is specified we can rely on `fractionCompleted`
            return progressObject.fractionCompleted
        } else {
            // if the Content-Length is not specified, return progress 0.0 until it's completed
            return 0.0
        }
    }

    /// A Boolean value stating whether the request is completed.
    public var completed: Bool {
        return response != nil
    }
}
