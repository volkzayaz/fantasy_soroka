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
import RxCocoa


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
    @IBOutlet weak var deleteDeckButton: UIButton!
    @IBOutlet weak var dotsImageView: UIImageView!
    @IBOutlet weak var deckStateImageView: UIImageView!
    private var gradientLayer = CAGradientLayer()
    
    var roomSettingsViewModel: RoomSettingsViewModel? = nil
    
    var model: Fantasy.Collection! {
        didSet {
            
            set(imageURL: model.imageURL)
            titleLabel.text = model.title
            paidLabel.text = model.category
            
            if model.wasPurchased {
                deckStateImageView.image = R.image.isPurchased()
            }
            else if let u = User.current, u.subscription.isSubscribed {
                deckStateImageView.image = R.image.parrot()
            }
            else {
                deckStateImageView.image = nil
            }
            
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
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

        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0.7]
    }
}

extension FantasyCollectionCollectionViewCell {
    @IBAction func deleteDeckButtonPressed(_ sender: Any) {
        roomSettingsViewModel?.deckOptionsPressed(collection: model)
    }
}
