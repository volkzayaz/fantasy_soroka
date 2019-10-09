//
//  PushManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class PushManager: NSObject {}
extension PushManager {
    
    static func updateDeviceToken(data: Data) {
        PFInstallation.current()?.setDeviceTokenFrom(data)
        let _ = PFInstallation.current()?.rxSave().retry(2).subscribe()
    }
    
    static func updateUserRelation(userId: String?) {
        
        if PFInstallation.current()?["userId"] as? String == userId {
            return
        }
        
        PFInstallation.current()?.setObject(userId as Any, forKey: "userId")
        let _ = PFInstallation.current()?.rxSave().retry(2).subscribe()
    }
    
    static func sendPush(to user: User, text: String) {
        
        let query = PFInstallation.query()! as! PFQuery<PFInstallation>
        query.whereKey("userId", equalTo: user.id)
        
        let push = PFPush()
        push.setQuery(query)
        push.setMessage(text)
        push.sendInBackground(block: nil)
        
    }
    
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge, .provisional],
                                  completionHandler: { _, _ in })
    }
    
    static func kickOff() {
        ///set the delegate
        UNUserNotificationCenter.current().delegate = instance
        
        ///get the token
        UIApplication.shared.registerForRemoteNotifications()
        
        ///with provisional authorization we can just do it without triggering a dialog
        self.requestNotificationPermission()
        
        ///keep lining user
        let _ =
        appState.changesOf { $0.currentUser?.id }
            .drive(onNext: { (x) in
                self.updateUserRelation(userId: x)
            })
    }
    
    private static let instance = PushManager()
    
}

extension PushManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response)
        
    }
    
}
