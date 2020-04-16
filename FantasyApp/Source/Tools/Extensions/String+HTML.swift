//
//  NSString+HTML.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 29.03.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

extension String {
  
  var htmlAttributed: NSAttributedString? {
    do {
      guard let data = data(using: String.Encoding.utf8) else {
        return nil
      }
      return try NSAttributedString(data: data,
                                    options: [.documentType: NSAttributedString.DocumentType.html,
                                              .characterEncoding: String.Encoding.utf8.rawValue],
                                    documentAttributes: nil)
    } catch {
      print("error: ", error)
      return nil
    }
  }
  
  func getHtmlAttributed() -> NSAttributedString? {
    do {
      
      let size = 16
      let sizeH1 = 18
      let font = UIFont.regularFont(ofSize: CGFloat(size)).familyName
      let color = UIColor.fantasyBlack.hexString!
      
      let css = "<style>html *{font-size:\(size);color:#\(color);font-family:\(font);}h2{font-size:\(sizeH1);color:#\(color);font-family:\(font);}</style>\(self)"
      
      guard let data = css.data(using: String.Encoding.utf8) else {
        return nil
      }
      
      return try NSAttributedString(data: data,
                                    options: [.documentType: NSAttributedString.DocumentType.html,
                                              .characterEncoding: String.Encoding.utf8.rawValue],
                                    documentAttributes: nil)
    } catch {
      print("error: ", error)
      return nil
    }
  }
}
