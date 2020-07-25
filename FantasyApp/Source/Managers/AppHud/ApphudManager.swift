//
//  ApphudService.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 24.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import ApphudSDK

public final class ApphudManager {
    
    enum Key: String {
        case isMigrated
    }
    
    public static func configure() {
        Apphud.start(apiKey: "app_njroWrHRCnxuooErNz6d7uCn4PZuwK")
        migrate()
    }
    
    public static func updateUserId(_ userId: String) {
        Apphud.updateUserID(userId)
    }
    
    // MARK: - Private
    
    private static func migrate() {
        let isMigrated: Bool = StorageManager.getValue(for: Key.isMigrated.rawValue) ?? false
        
        if isMigrated == false {
            Apphud.migratePurchasesIfNeeded { _, _, _ in }
            StorageManager.setValue(value: true, forKey: Key.isMigrated.rawValue)
        }
    }
}
