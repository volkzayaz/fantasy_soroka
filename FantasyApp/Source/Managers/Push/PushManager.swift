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
        ApphudManager.submitNotificationsToken(data)
        let _ = PFInstallation.current()?.rxSave().retry(2).subscribe()
    }
    
    static func updateUserRelation(userId: String?) {
        
        if PFInstallation.current()?["userId"] as? String == userId {
            return
        }
        
        PFInstallation.current()?.setObject(userId as Any, forKey: "userId")
        let _ = PFInstallation.current()?.rxSave().retry(2).subscribe()
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
        
        //Branch.getInstance()?.handlePushNotification(  userInfo)
        
        ApphudManager.handlePush(with: response.notification)
        
        guard let data = try? JSONSerialization.data(withJSONObject: response.notification.request.content.userInfo, options: []) else {
            return
        }
        
        if let x = try? JSONDecoder().decode(NewMessageNotification.self, from: data) {
            Dispatcher.dispatch(action: ChangeOpeRoomRef(roomRef: x.roomRef) )
            return
        }
    }
        
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        ApphudManager.handlePush(with: notification)
        completionHandler([])
    }
}

struct NewMessageNotification: Decodable {
    let roomId: String
    
    var roomRef: RoomRef {
        return .init(id: roomId)
    }
}
