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
    @IBOutlet weak var secondaryContentView: UIView!

    @IBOutlet weak var profileImageView: ProtectedImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelPhotoNumber: UILabel!

    @IBOutlet weak var transparentGradienView: UIView!

    private var bag = DisposeBag()
    private let gradientLayer = CAGradientLayer()
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
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
        }

//        setupShadow()
        setupTransparentGradient()
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

    private func setupTransparentGradient() {
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.9).cgColor
        ]

        transparentGradienView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.frame = transparentGradienView.bounds
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: corner).cgPath
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

        profileImageView.reset()
        profileImageView.set(imageURL: data.bio.photos.avatar.url,
                             isProtected: data.subscription.isSubscribed,
                             errorPlaceholder: R.image.noPhoto())
        
    }
}

// MARK:- Animation Transition

extension UserCarouselView {

    func animateAppearance() {
//        storyView.alpha = 0.0
//        shareButton.alpha = 0.0
//        paidCardView.alpha = 0.0
        UIView.animate(withDuration: 0.2,
                       delay: DiscoverProfileRouterTransitionAnimator.durationClosing,
                       options: .curveEaseIn,
                       animations: {
//            self.storyView.alpha = 1.0
//            self.shareButton.alpha = 1.0
//            self.paidCardView.alpha = 1.0
        })

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + DiscoverProfileRouterTransitionAnimator.durationClosing
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "fade")
    }

    func animateDisappearance() {
//           storyView.alpha = 1.0
//           shareButton.alpha = 1.0
//           paidCardView.alpha = 1.0
           UIView.animate(withDuration: 0.2,
                          delay: FantasyDetailsTransitionAnimator.durationExpanding,
                          options: .curveEaseIn,
                          animations: {
//               self.storyView.alpha = 0.0
//               self.shareButton.alpha = 0.0
//               self.paidCardView.alpha = 0.0
           })

           let animation = CABasicAnimation(keyPath: "opacity")
           animation.fromValue = 1.0
           animation.toValue = 0.0
           animation.duration = 0.2
           animation.beginTime = CACurrentMediaTime() + FantasyDetailsTransitionAnimator.durationExpanding
           animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
           gradientLayer.add(animation, forKey: "fade")
       }

}
