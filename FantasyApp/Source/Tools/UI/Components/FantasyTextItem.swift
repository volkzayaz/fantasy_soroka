//
//  FantasyTextItem.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyTextItem: UIBarButtonItem {

    override func awakeFromNib() {
        super.awakeFromNib()

        setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 16.0),
            NSAttributedString.Key.foregroundColor: UIColor.white],
                               for: UIControl.State.normal)
    }
}
