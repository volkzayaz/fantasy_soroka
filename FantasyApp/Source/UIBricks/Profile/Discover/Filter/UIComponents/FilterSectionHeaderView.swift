//
//  FilterSectionHeaderView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 23.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FilterSectionHeaderView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = UIFont.regularFont(ofSize: 25)
            label.textColor = R.color.textBlackColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        backgroundColor = UIColor.clear
        addSubview(contentView)
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: String(describing: type(of:self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}

//MARK:- Public

extension FilterSectionHeaderView {

    public func setData(value:String?) {
        label.text = value
    }
}
