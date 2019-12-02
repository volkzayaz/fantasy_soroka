//
//  NotificationService.swift
//  FantasyAppRichPush
//
//  Created by Vlad Soroka on 02.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UserNotifications


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        let url = URL(string: "")!
        
        URLSession.init(configuration: .default).downloadTask(with: url) { (temporaryFileLocation, response, error) in
            
            if let _ = error {
                return contentHandler(self.bestAttemptContent!)
            }
            
            let attachmentURL = URL(fileURLWithPath: temporaryFileLocation!.path.appending((response!.url!.absoluteString as NSString).lastPathComponent))
            
            try! FileManager.default.moveItem(at: temporaryFileLocation!, to: attachmentURL)
            
            let attachment = try! UNNotificationAttachment(identifier: "", url: attachmentURL, options: nil)
            
            self.bestAttemptContent!.attachments = [attachment]
            contentHandler(self.bestAttemptContent!)
            
        }
        .resume()
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
