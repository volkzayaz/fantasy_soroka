//
//  StorageManger.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 13.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

final class StorageManager {
        
    static func getValue<T>(for key: String) -> T? {
        UserDefaults.standard.value(forKey: key) as? T
    }
    
    static func setValue<T>(value: T, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
