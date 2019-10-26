//
//  UserCarouselView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 26.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class UserCarouselView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelPhotoNumber: UILabel!

    @IBOutlet weak var transparentGradienView: UIView!

    private var bag = DisposeBag()
    private let gradientLayer = CAGradientLayer()
    private var shadowLayer: CAShapeLayer?

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
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
        }

        setupShadow()
        setupTransparentGradient()
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
        contentView.layer.insertSublayer(shadowLayer!, at: 0)
    }

    private func setupTransparentGradient() {
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.9).cgColor
        ]

        transparentGradienView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.frame = transparentGradienView.bounds
    }
}

// MARK:- Public

extension UserCarouselView {

    func setUser(_ data: User) {

        let photoCount = data.bio.photos.public.images.count + data.bio.photos.private.images.count
        let cardCount = data.fantasies.liked.count + data.fantasies.disliked.count

        labelName.text = data.bio.name
        labelPhotoNumber.text = "\(photoCount)"
        labelCardNumber.text = "\(cardCount)"
        starImageView.isHidden = !data.subscription.isSubscribed

        ImageRetreiver.imageForURLWithoutProgress(url: data.bio.photos.avatar.url)
            .map { $0 ?? R.image.noPhoto() }
            .drive(profileImageView.rx.image)
            .disposed(by: bag)
    }
}
