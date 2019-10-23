//
//  SwipeableCell.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 22.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import SmoothPicker

class SwipeableCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel!{
        didSet {
            cellNameLabel.font = UIFont.regularFont(ofSize: 15)
            cellNameLabel.textColor = R.color.textBlackColor()
        }
    }
    @IBOutlet weak var cellDescriptionLabel: UILabel! {
        didSet {
            cellDescriptionLabel.font = UIFont.regularFont(ofSize: 15)
            cellDescriptionLabel.textColor = R.color.textLightGrayColor()
        }
    }
    @IBOutlet weak var smoothPickerView: SmoothPickerView! {
        didSet {
            smoothPickerView.delegate = self
            smoothPickerView.dataSource = self
        }
    }

    var list: [String] = []
    var selectedValue: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

//MARK:- Public

extension SwipeableCell {

    public func setData(title: String, description: String, list: [String], selected: String) {
        cellNameLabel.text = title
        cellDescriptionLabel.text = description

        self.list = list
        self.selectedValue = selected

        smoothPickerView.reloadData()
    }
}


//MARK:- SmoothPickerViewDelegate, SmoothPickerViewDataSource

extension SwipeableCell: SmoothPickerViewDelegate, SmoothPickerViewDataSource {

    func didSelectItem(index: Int, view: UIView, pickerView: SmoothPickerView) {

    }

    func numberOfItems(pickerView: SmoothPickerView) -> Int {
        return list.count
    }

    func itemForIndex(index: Int, pickerView: SmoothPickerView) -> UIView {

        guard list.count > index + 1 else {
            return UIView()
        }

        let itemView = SwipeView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        itemView.setData(value: list[index])

        return itemView
    }

}
