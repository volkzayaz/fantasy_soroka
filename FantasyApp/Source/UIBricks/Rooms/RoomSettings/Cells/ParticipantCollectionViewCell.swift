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
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var statusLabelContainer: UIView!
    @IBOutlet private (set) var imageView: UIImageView!

    var status: Chat.RoomParticipantStatus? {
        didSet {
            guard let status = status else {
                statusLabel.isHidden = true
                return
            }

            switch status {
            case .accepted:
                statusLabel.text = R.string.localizable.roomParticipantStatusAccepted()
                statusLabel.textColor = .participantAccepted
            case .invited:
                statusLabel.text = R.string.localizable.roomParticipantStatusInvited()
                statusLabel.textColor = .participantInvited
            case .rejected:
                statusLabel.text = R.string.localizable.roomParticipantStatusRejected()
                statusLabel.textColor = .participantRejected
            }

            statusLabel.isHidden = false
            statusLabelContainer.isHidden = false
            statusLabelContainer.backgroundColor = statusLabel.textColor.withAlphaComponent(0.2)
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2.0
        statusLabelContainer.layer.cornerRadius = statusLabelContainer.bounds.size.height / 2.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        adminLabel.isHidden = true
        statusLabelContainer.isHidden = true
        statusLabel.isHidden = true
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
        adminLabel.textAlignment = .center
        adminLabel.text = R.string.localizable.roomCreationParticipantsAdmin()
        statusLabel.font = .boldFont(ofSize: 12)
        statusLabelContainer.clipsToBounds = true
    }
}
