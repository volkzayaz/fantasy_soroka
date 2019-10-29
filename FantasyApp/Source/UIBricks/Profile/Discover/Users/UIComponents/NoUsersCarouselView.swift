//
//  NoUsersCarouselView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

protocol NoUsersCarouselViewDelegate {
    func inviteFriends()
    func showFilters()
}

class NoUsersCarouselView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var secondaryContentView: UIView!

    var delegate: NoUsersCarouselViewDelegate?
    private let corner: CGFloat = 20.0

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
        secondaryContentView.clipsToBounds = true
        secondaryContentView.layer.cornerRadius = corner

        addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        setupShadow()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: String(describing: type(of:self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }

    private func setupShadow() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.7
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.layer.shadowRadius = 10
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: corner).cgPath
    }
}

//MARK:- Actions

extension NoUsersCarouselView {
    @IBAction func inviteFriendsClick(_ sender: Any) {
        delegate?.inviteFriends()
    }

    @IBAction func filters(_ sender: Any) {
        delegate?.showFilters()
    }
}
