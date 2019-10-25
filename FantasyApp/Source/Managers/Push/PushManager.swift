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
    
    static func sendPush(to user: UserIdentifier, text: String) {

        
//        NSString *alertString = [NSString stringWithFormat:message, currentUser.realname];
//
//        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
//        [userInfo setValue:activity.objectId forKey:@"activity"];
//
//        [data setValue:alertString forKey:@"alert"];
//        [data setValue:@"bingbong.aiff" forKey:@"sound"];
//        [data setValue:userInfo forKey:@"userInfo"];
//        [data setValue:user.objectId forKey:@"userId"];
//        [data setValue:@"Increment" forKey:@"badge"];
//
//        NSError *error = nil;
//        [PFCloud callFunction:@"sendPush" withParameters:data error:&error];
        
        let params = [
            "alert": text,
            "userId": user.id
        ]
        
        PFCloud.callFunction(inBackground: "sendPush",
                             withParameters: params) { (value, error) in
                                print("error")
        }
        
    }
    
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge],
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
        
        //Branch.getInstance()?.handlePushNotification(  userInfo)
        
        print(response)
        
    }
    
}
