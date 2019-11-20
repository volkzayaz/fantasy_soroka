//
//  ProfileSettingsHeaderView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class ProfileSettingsHeaderView: UIView {

    @IBOutlet weak var label: UILabel!

    static var instance: ProfileSettingsHeaderView {
        return UINib.init(nibName: "ProfileSettingsHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ProfileSettingsHeaderView
      }

    func setText(_ text: String) {
        label.text = text
    }
}
