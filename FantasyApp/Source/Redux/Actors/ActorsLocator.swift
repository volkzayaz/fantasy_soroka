//
//  ActorsLocator.swift
//  FantasyApp
//
//  Created by Admin on 14.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

public protocol ActorLocating {
    func register<T>(_ actor: T)
}

public class ActorLocator: ActorLocating {
    private lazy var actors: Dictionary<String, Any> = [:]

    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

    public func register<T>(_ actor: T) {
        let key = typeName(T.self)
        actors[key] = actor
    }

    public static let shared = ActorLocator()
}
