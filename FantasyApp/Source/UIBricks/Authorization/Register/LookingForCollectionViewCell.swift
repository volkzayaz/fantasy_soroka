//
//  LookingForCollectionViewCell.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 16.11.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class LookingForCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = contentView.bounds.height / 2
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.masksToBounds = true
        
        updateSelectionState()
    }
    
    func configure(lookingFor: LookingFor) {
        titleLabel.text = lookingFor.title
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleLabel: UILabel!
}

private extension LookingForCollectionViewCell {
    
    func updateSelectionState() {
        titleLabel.textColor = isSelected ? UIColor(fromHex: 0xD364B1) : .white
        contentView.backgroundColor = isSelected ? .white : .clear
    }
}
