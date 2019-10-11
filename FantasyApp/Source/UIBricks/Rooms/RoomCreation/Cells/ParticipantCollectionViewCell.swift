//
//  ParticipantCollectionViewCell.swift
//  FantasyApp
//
//  Created by Admin on 11.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    @IBOutlet private (set) var nameLabel: UILabel!
    @IBOutlet private (set) var adminLabel: UILabel!
    @IBOutlet private (set) var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        adminLabel.isHidden = true
    }
}

private extension ParticipantCollectionViewCell {
    func configure() {
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        nameLabel.textColor = .fantasyBlack
        nameLabel.font = .mediumFont(ofSize: 15)
        adminLabel.textColor = .basicGrey
        adminLabel.font = .regularFont(ofSize: 12)
        adminLabel.text = R.string.localizable.roomCreationParticipantsAdmin()
    }
}
