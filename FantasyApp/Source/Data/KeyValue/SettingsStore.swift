//
//  SettingsStore.swift
//
//  Created by Vlad Soroka on 8/27/18.
//  Copyright © 2018 Vlad Soroka. All rights reserved.
//

import Foundation

enum SettingsStore {}
extension SettingsStore {
    
    static var lastUsedEmail: Setting<String?> = Setting(key: "com.fantasyapp.iosclient.settings.lastUsedEmail",
                                                           initialValue: nil)
    
}
