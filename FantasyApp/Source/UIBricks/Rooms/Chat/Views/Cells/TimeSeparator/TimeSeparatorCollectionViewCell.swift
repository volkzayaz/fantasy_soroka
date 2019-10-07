//
//  TimeSeparatorCollectionViewCell.swift
//  FantasyApp
//
//  Created by Admin on 30.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import UIKit
import Chatto

class TimeSeparatorCollectionViewCell: UICollectionViewCell {
    private let labelContainer = UIView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.backgroundColor = .clear
        labelContainer.layer.borderColor = UIColor.messageBackground.cgColor
        labelContainer.layer.borderWidth = 1.0
        labelContainer.layer.cornerRadius = 9.0
        labelContainer.clipsToBounds = true
        contentView.addSubview(labelContainer)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .semiBoldFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .basicGrey
        label.backgroundColor = .clear
        labelContainer.addSubview(label)

        NSLayoutConstraint.activate([
            labelContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            labelContainer.heightAnchor.constraint(equalToConstant: 20),
            labelContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            label.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            label.leftAnchor.constraint(equalTo: labelContainer.leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: labelContainer.rightAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
        ])
    }

    var text: String = "" {
        didSet {
            label.text = text
        }
    }
}
