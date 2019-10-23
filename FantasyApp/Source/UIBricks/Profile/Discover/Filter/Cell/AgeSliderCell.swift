//
//  AgeSliderCell.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 22.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import MultiSlider

class AgeSliderCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel! {
        didSet {
            cellNameLabel.font = UIFont.regularFont(ofSize: 15)
            cellNameLabel.textColor = R.color.textBlackColor()
            cellNameLabel.text = "Age"
        }
    }

    @IBOutlet weak var multiSlider: MultiSlider! {
        didSet {
            multiSlider.minimumValue = 18.0
            multiSlider.maximumValue = 100.0
            multiSlider.orientation = .horizontal
            multiSlider.valueLabelPosition = .bottom
            multiSlider.snapStepSize = 1.0

            multiSlider.outerTrackColor = .gray
            multiSlider.value = [30, 31]
            multiSlider.tintColor = .purple
            multiSlider.trackWidth = 11
            multiSlider.showsThumbImageShadow = false
            multiSlider.keepsDistanceBetweenThumbs = true

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

//MARK:- Public

extension AgeSliderCell {

    public func setData(minValue: Int, maxValue: Int) {
        multiSlider.value = [
            CGFloat(minValue),
            CGFloat(maxValue)
        ]
    }
}
