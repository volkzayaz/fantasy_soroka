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
             cellNameLabel.text = "Couple"
        }
    }
    @IBOutlet weak var ageSwitch: UISwitch! {
        didSet {
            ageSwitch.onTintColor = R.color.textPinkColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

//MARK:- Public

extension SwitchableCell {

    public func setData(isOn: Bool) {
        ageSwitch.isOn = isOn
    }
}
