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
    @IBOutlet weak var filtersButton: PrimaryButton!

    private var shadowLayer: CAShapeLayer?

    var delegate: NoUsersCarouselViewDelegate?

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
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 20

        addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
//            make.top.equalTo(self.snp.top)
//            make.bottom.equalTo(self.snp.bottom)
//            make.left.equalTo(self.snp_left)
//            make.right.equalTo(self.snp_right)
            make.edges.equalTo(self)

        }

        setupShadow()
        filtersButton.addLightGrayColorStyle()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: String(describing: type(of:self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }

    private func setupShadow() {
        if let layer = shadowLayer {
            layer.removeFromSuperlayer()
        }
        shadowLayer = CAShapeLayer()
        shadowLayer!.fillColor = UIColor.white.cgColor
        shadowLayer!.shadowRadius = 20
        shadowLayer!.shadowOpacity = 0.5
        shadowLayer!.shadowColor = UIColor.shadow.cgColor
        shadowLayer!.shadowOffset = CGSize(width: 9.0, height: 6.0)
        layer.insertSublayer(shadowLayer!, at: 0)
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
