//
//  InviteParticipantCollectionViewCell.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class InviteParticipantCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2.0
    }
}

private extension InviteParticipantCollectionViewCell {
    func configure() {
        backgroundColor = .clear
        imageView.backgroundColor = .fantasyGrey
        imageView.contentMode = .center
        imageView.image = R.image.invite()
        titleLabel.textColor = .fantasyPink
        titleLabel.font = .boldFont(ofSize: 16)
        titleLabel.text = R.string.localizable.roomCreationParticipantsAdd()
    }
}

