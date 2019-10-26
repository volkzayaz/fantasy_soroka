//
//  SwipeView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 23.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

protocol SwipebleModel {
    var name: String { get }
}

class SwipeView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = normalFont
            label.textColor = R.color.textLightGrayColor()
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

    var normalFont = UIFont.regularFont(ofSize: 18)
    var selectedFont = UIFont.regularFont(ofSize: 22)

    override func setSmoothSelected(_ selected: Bool) {
        label.textColor = selected ? R.color.textPinkColor() : R.color.textLightGrayColor()
        label.font = selected ? selectedFont : normalFont
    }

    var data: SwipebleModel? {
        didSet {
            label.text = data?.name
            label.sizeToFit()

            var f = frame
            f.size.width = label.bounds.width + 40
            frame = f
        }
    }
}
