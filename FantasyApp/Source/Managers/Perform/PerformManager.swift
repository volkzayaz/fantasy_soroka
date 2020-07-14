//
//  PerformManager.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 13.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

typealias PerformCallback = () -> Void

enum PerformRule {
    case once
    case on(Int)
    case every(Int)
}

enum PerformEvent: String {
    case subscriptionOfferShownInFlirt
}

enum PerformAccessLevel {
    case global, local(id: String)
}

final class PerformManager {
            
    static func perform(rule: PerformRule, event: PerformEvent, accessLevel: PerformAccessLevel = .global, callback: PerformCallback) {
        let key = "perform_event.\(event.rawValue).\(rule.name).\(accessLevel.name)"

        switch rule {
        case .once:
            guard let value: Bool = StorageManager.getValue(for: key) ?? false, value == false else { return }

            callback()
            StorageManager.setValue(value: true, forKey: key)

        case .on(let count):
            guard var value: Int = StorageManager.getValue(for: key) else {
                StorageManager.setValue(value: 1, forKey: key)
                return
            }

            value += 1

            if value == count {
                callback()
            }

            StorageManager.setValue(value: value, forKey: key)

        case .every(let count):
            guard var value: Int = StorageManager.getValue(for: key) else {
                StorageManager.setValue(value: 1, forKey: key)
                return
            }

            value += 1

            if value % count == 0 {
                callback()
            }

            StorageManager.setValue(value: value, forKey: key)
        }
    }
}

extension PerformRule {
    
    var name: String {
        switch self {
        case .once: return "once"
        case .every(let count): return "count_\(count)"
        case .on(let count): return "on_count_\(count)"
        }
    }
}

extension PerformAccessLevel {
    
    var name: String {
        switch self {
        case .global: return "global"
        case .local(let id): return "local_\(id)"
        }
    }
}
