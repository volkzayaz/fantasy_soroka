//
//  AddCollectionViewCell.swift
//  FantasyApp
//
//  Created by Максим Сорока on 18.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class AddDeckCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .fantasyGrey
        addLabel.textColor = .fantasyPink
        plusImageView.image = R.image.invite()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 17
    }
}
