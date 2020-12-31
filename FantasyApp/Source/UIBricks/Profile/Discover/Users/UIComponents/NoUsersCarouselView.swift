//
//  NoUsersCarouselView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol NoUsersCarouselViewDelegate {
    func inviteFriends()
    func goGlobal()
}

class NoUsersCarouselView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var secondaryContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = R.string.localizable.profileDiscoverUsersNoUsersTitle()
        }
    }

    @IBOutlet weak var inviteButton: UIButton! {
        didSet {
            inviteButton.setTitle(R.string.localizable.profileDiscoverUsersNoUsersInvite(), for: .normal)
        }
    }
    
    @IBOutlet weak var goGlobalButton: UIButton! {
        didSet {
            goGlobalButton.setTitle(R.string.localizable.profileDiscoverUsersNoUsersGoGlobal(), for: .normal)
        }
    }
    
    var delegate: NoUsersCarouselViewDelegate?
    private let corner: CGFloat = 20.0

    init(frame: CGRect, isGoGlobalHidden: Driver<Bool>) {
        super.init(frame: frame)
        
        nibSetup()
        isGoGlobalHidden
            .drive(goGlobalButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func nibSetup() {
        contentView = loadViewFromNib()
        secondaryContentView.clipsToBounds = true
        secondaryContentView.layer.cornerRadius = corner

        addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

//        setupShadow()
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

    @IBAction func goGlobal(_ sender: Any) {
        delegate?.goGlobal()
    }
}
