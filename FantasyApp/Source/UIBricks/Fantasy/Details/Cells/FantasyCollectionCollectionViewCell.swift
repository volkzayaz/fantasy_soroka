//
//  FantasyCollectionCollectionViewCell.swift
//  FantasyApp
//
//  Created by Admin on 28.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift

class FantasyCollectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var paidView: UIView!
    @IBOutlet private var paidLabel: UILabel!
    @IBOutlet private var paidImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var fantasiesCountLabel: UILabel!
    private var gradientLayer = CAGradientLayer()

    private var disposeBag = DisposeBag()

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var fantasiesCount: Int = 0 {
        didSet {
            fantasiesCountLabel.text = R.string.localizable.fantasyCollectionCardsCount(fantasiesCount)
        }
    }

    var isPaid: Bool = false {
        didSet {
            paidView.isHidden = !isPaid
        }
    }

    var imageURL: String? {
        didSet {
            guard let imageURL = imageURL else {
                imageView.image = nil
                return
            }
            ImageRetreiver.imageForURLWithoutProgress(url: imageURL)
                .drive(imageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyling()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        paidView.isHidden = true
        disposeBag = DisposeBag()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        paidView.layer.cornerRadius = paidView.frame.height / 2.0
        gradientLayer.frame = bounds
    }

    private func configureStyling() {
        layer.cornerRadius = 16.0
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.layer.addSublayer(gradientLayer)

        paidImageView.image = R.image.paidCollection()

        paidView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        paidView.clipsToBounds = true

        paidLabel.text = R.string.localizable.fantasyCollectionPaidIndicator()
        paidLabel.textColor = .title
        paidLabel.font = .mediumFont(ofSize: 12)

        titleLabel.textColor = .title
        titleLabel.font = .boldFont(ofSize: 15)

        fantasiesCountLabel.textColor = .title
        fantasiesCountLabel.font = .regularFont(ofSize: 15)

        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0.7]
    }
}
