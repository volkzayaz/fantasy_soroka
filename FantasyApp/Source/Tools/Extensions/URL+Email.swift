//
//  URL+Email.swift
//  FantasyApp
//
//  Created by Afanasiev, Anatolii on 14/04/2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

extension URL {
  
  static func emailUrl(to: String, subject: String, body: String) -> URL? {
  
    let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
      let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

      let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
      let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

      if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
        
        return gmailUrl
        
      } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
        
        return outlookUrl
        
      } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
        
        return yahooMail
        
      } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
        
        return sparkUrl
        
      }

      return defaultUrl
  }
}
