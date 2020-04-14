//
//  FantasyCollectionCollectionViewCell.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 28.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

struct FantasyCollectionCellModel: IdentifiableType, Equatable {
    var identity: String {
        return uid
    }

    let uid: String
    let isPaid: Bool
    let title: String
    let cardsCount: Int
    let imageURL: String
}

class FantasyCollectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: ProtectedImageView!
    @IBOutlet var paidView: UIView!
    @IBOutlet var paidLabel: UILabel!
    @IBOutlet var paidImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fantasiesCountLabel: UILabel!
    private var gradientLayer = CAGradientLayer()

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
           // paidView.isHidden = !isPaid
        }
    }

    func set(imageURL: String) {
        imageView.set(imageURL: imageURL, isProtected: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyling()
        
        title = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        paidView.isHidden = true
        imageView.reset()
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
