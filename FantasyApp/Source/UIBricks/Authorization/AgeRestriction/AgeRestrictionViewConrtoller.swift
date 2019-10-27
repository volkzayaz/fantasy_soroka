//
//  AgeRestrictionViewConrtoller.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 23.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class AgeRestrictionViewConrtoller: UIViewController {
    
    @IBOutlet weak var roundedView: UIView! {
        didSet {
            roundedView.addFantasyRoundedCorners()
        }
    }

    @IBAction func backToSignIn(_ sender: Any) {

    }
}
