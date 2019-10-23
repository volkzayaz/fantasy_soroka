//
//  SwitchableCell.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 23.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class SwitchableCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel!{
        didSet {
            cellNameLabel.font = UIFont.regularFont(ofSize: 15)
            cellNameLabel.textColor = R.color.textBlackColor()
        }
    }
    @IBOutlet weak var ageSwitch: UISwitch! {
        didSet {
            cellNameLabel.font = UIFont.regularFont(ofSize: 15)
            cellNameLabel.textColor = R.color.textLightGrayColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
