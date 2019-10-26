//
//  ListRoundedView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 25.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class ListRoundedView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        layer.cornerRadius = 15
    }
}
