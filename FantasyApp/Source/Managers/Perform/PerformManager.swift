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

enum PerformEvent {
    case subscriptionPromoOfferShownInFlirt
    case subscriptionSpecialOfferShownInFlirt
    case flirtOptionsShownInFlirt
    case customName(String)
}

enum PerformAccessLevel {
    case global, local(id: String)
}

final class PerformManager {
    
    static func willPerform(rule: PerformRule, event: PerformEvent, accessLevel: PerformAccessLevel = .global) -> Bool {
        let key = PerformManager.key(rule: rule, event: event, accessLevel: accessLevel)
        
        switch rule {
        case .once:
            return !(StorageManager.getValue(for: key) ?? false)
        case .on(let count):
            return StorageManager.getValue(for: key) ?? 0 < count
        case .every(let count):
            if let value: Int = StorageManager.getValue(for: key), value % count == 0 {
                return true
            } else {
                return false
            }
        }
    }
    
    static func perform(rule: PerformRule, event: PerformEvent, accessLevel: PerformAccessLevel = .global, callback: PerformCallback) {
        let key = PerformManager.key(rule: rule, event: event, accessLevel: accessLevel)

        switch rule {
        case .once:
            guard let value: Bool = StorageManager.getValue(for: key) ?? false, value == false else { return }

            callback()
            StorageManager.setValue(value: true, forKey: key)

        case .on(let count):
            guard var value: Int = StorageManager.getValue(for: key) else {
                StorageManager.setValue(value: 1, forKey: key)
                
                if 1 == count {
                    callback()
                }
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

private extension PerformManager {
    
    static func key(rule: PerformRule, event: PerformEvent, accessLevel: PerformAccessLevel) -> String {
        "perform_event.\(event.name).\(rule.name).\(accessLevel.name)"
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

extension PerformEvent {
    
    var name: String {
        switch self {
        case .subscriptionPromoOfferShownInFlirt: return "subscriptionPromoOfferShownInFlirt"
        case .subscriptionSpecialOfferShownInFlirt: return "subscriptionSpecialOfferShownInFlirt"
        case .flirtOptionsShownInFlirt: return "flirtOptionsShownInFlirt"
        case .customName(let name): return "customName.\(name)"
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
