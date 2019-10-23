//
//  SelectCityTableViewCell.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 22.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class SelectCityCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel! {
        didSet {
            cellNameLabel.font = UIFont.regularFont(ofSize: 15)
            cellNameLabel.textColor = R.color.textBlackColor()
            cellNameLabel.text = "Search City"
        }
    }

    @IBOutlet weak var cityNameLabel: UILabel! {
        didSet {
            cityNameLabel.font = UIFont.regularFont(ofSize: 15)
            cityNameLabel.textColor = R.color.textPinkColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

//MARK:- Public

extension SelectCityCell {

    public func setData(value:String) {
        cityNameLabel.text = value
    }
}
