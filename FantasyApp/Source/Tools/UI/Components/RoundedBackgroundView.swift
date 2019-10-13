//
//  RoundedBackgroundView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 13.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class RoundedBackgroundView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

}
