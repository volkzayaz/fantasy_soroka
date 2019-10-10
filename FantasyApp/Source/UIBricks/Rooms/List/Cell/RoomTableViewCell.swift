//
//  RoomTableViewCell.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
    @IBOutlet private (set) var nameLabel: UILabel!
    @IBOutlet private (set) var timeLabel: UILabel!
    @IBOutlet private (set) var lastMessageLabel: UILabel!
    @IBOutlet private var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
}

private extension RoomTableViewCell {
    func configure() {
        selectionStyle = .none
        separator.backgroundColor = UIColor.basicGrey.withAlphaComponent(0.18)
        nameLabel.textColor = .fantasyBlack
        nameLabel.font = .boldFont(ofSize: 15)
        lastMessageLabel.textColor = .fantasyBlack
        lastMessageLabel.font = .regularFont(ofSize: 15)
        timeLabel.textColor = .basicGrey
        timeLabel.font = .regularFont(ofSize: 12)
    }
}
