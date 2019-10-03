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

    static var currentUser: Setting<User?> = Setting(key: "com.fantasyapp.iosclient.settings.currentUser",
                                                     initialValue: nil)
    
    ///Questionable state based on stakeholders "I want!"
    ///Most likely will become obsolete soon
    
    static var ageRestriction: Setting<Date?> = Setting(key: "com.fantasyapp.iosclient.settings.ageRestriction",
                                                     initialValue: nil)
    
    static var atLeastOnceLocation: Setting<Bool?> = Setting(key: "com.fantasyapp.iosclient.settings.atLeastOnceLocation",
                                                            initialValue: nil)
}
