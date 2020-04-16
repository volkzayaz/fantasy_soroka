//
//  FantasyDeckItemView.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import SnapKit

class FantasyDeckItemView: UIView {

    var isPaid: Bool = false {
        didSet {
            //paidCardView.isHidden = !isPaid
        }
    }

    var hasStory: Bool = false {
        didSet {
            storyView.isHidden = !hasStory
        }
    }

    var imageURL: String? {
        didSet {
            
            guard let x = imageURL else {
                imageView.reset()
                return
            }
            
            imageView.set(imageURL: x, isProtected: true)
            
        }
    }

    private let imageView = ProtectedImageView(frame: .zero)
    private let paidCardView = UIView(frame: .zero)
    private let paidCardLabel = UILabel(frame: .zero)
    private let paidCardImageView = UIImageView(frame: .zero)

    private let storyView = UIView(frame: .zero)
    private let storyLabel = UILabel(frame: .zero)

    private let shareButton = UIButton(frame: .zero)

    private var gradientLayer = CAGradientLayer()

    var card: Fantasy.Card! {
        didSet {
            paidCardLabel.text = card.category //R.string.localizable.fantasyCardPaidIndicator()
        }
    }
    var viewModel: FantasyDeckViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStyling()
        configureLayout()
        
        shareButton.addTarget(self, action: "share", for: .touchUpInside)
    }

    @objc func share() {
        viewModel.share(card: card)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureStyling()
        configureLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        paidCardView.layer.cornerRadius = paidCardView.frame.height / 2.0
        storyView.layer.cornerRadius = storyView.frame.height / 2.0
        gradientLayer.frame = bounds
    }

    func animateDisappearance() {
        storyView.alpha = 1.0
        shareButton.alpha = 1.0
        paidCardView.alpha = 1.0
        UIView.animate(withDuration: 0.2,
                       delay: FantasyDetailsTransitionAnimator.durationExpanding,
                       options: .curveEaseIn,
                       animations: {
            self.storyView.alpha = 0.0
            self.shareButton.alpha = 0.0
            self.paidCardView.alpha = 0.0
        })

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + FantasyDetailsTransitionAnimator.durationExpanding
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "fade")
    }

    func animateAppearance() {
        storyView.alpha = 0.0
        shareButton.alpha = 0.0
        paidCardView.alpha = 0.0
        UIView.animate(withDuration: 0.2,
                       delay: FantasyDetailsTransitionAnimator.durationClosing,
                       options: .curveEaseIn,
                       animations: {
            self.storyView.alpha = 1.0
            self.shareButton.alpha = 1.0
            self.paidCardView.alpha = 1.0
        })

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + FantasyDetailsTransitionAnimator.durationClosing
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "fade")
    }
}

private extension FantasyDeckItemView {
    func configureLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(paidCardView)
        addSubview(shareButton)
        addSubview(storyView)

        paidCardView.addSubview(paidCardImageView)
        paidCardView.addSubview(paidCardLabel)

        storyView.addSubview(storyLabel)

        imageView.layer.addSublayer(gradientLayer)

        [imageView,
         paidCardView,
         shareButton,
         storyView,
         paidCardImageView,
         paidCardLabel,
         storyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            paidCardView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            paidCardView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            paidCardView.heightAnchor.constraint(equalToConstant: 34),
            paidCardView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -16),
            
            shareButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            shareButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40),

            storyView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            storyView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            storyView.heightAnchor.constraint(equalToConstant: 40),

            paidCardImageView.leftAnchor.constraint(equalTo: paidCardView.leftAnchor, constant: 12),
            paidCardImageView.centerYAnchor.constraint(equalTo: paidCardView.centerYAnchor),
            paidCardImageView.widthAnchor.constraint(equalToConstant: 14),
            paidCardImageView.heightAnchor.constraint(equalToConstant: 18),

            paidCardLabel.leftAnchor.constraint(equalTo: paidCardImageView.rightAnchor, constant: 5),
            paidCardLabel.centerYAnchor.constraint(equalTo: paidCardView.centerYAnchor),
            paidCardLabel.rightAnchor.constraint(equalTo: paidCardView.rightAnchor, constant: -12),

            storyLabel.leftAnchor.constraint(equalTo: storyView.leftAnchor, constant: 10),
            storyLabel.rightAnchor.constraint(equalTo: storyView.rightAnchor, constant: -10),
            storyLabel.centerXAnchor.constraint(equalTo: storyView.centerXAnchor),
            storyLabel.centerYAnchor.constraint(equalTo: storyView.centerYAnchor)
        ])
    }

    func configureStyling() {
        layer.cornerRadius = 23.0
        clipsToBounds = true
        backgroundColor = UIColor(fromHex: 0xadd8e6)
        
        imageView.contentMode = .scaleAspectFill

        paidCardView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        paidCardView.clipsToBounds = true

        storyView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        storyView.clipsToBounds = true

        paidCardImageView.image = R.image.paidCard()
        shareButton.setImage(R.image.shareCard(), for: .normal)

        storyLabel.text = R.string.localizable.fantasyCardStoryIndicator()
        storyLabel.textColor = .title
        storyLabel.font = .boldFont(ofSize: 16)
        storyLabel.textAlignment = .center

        paidCardLabel.textColor = .title
        paidCardLabel.font = .semiBoldFont(ofSize: 15)

        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0.7]

    }
}
