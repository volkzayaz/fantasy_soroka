//
//  UIDismissSegue.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 21.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        self.source.presentingViewController?.dismiss(animated: true, completion: nil)
   }
}
