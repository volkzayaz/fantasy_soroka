//
//  FantasyListCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

import ScreenShieldKit

class FantasyListCell: UICollectionViewCell {
    
    @IBOutlet weak var protectedImageView: ProtectedImageView!
    @IBOutlet weak var viewedIndicator: UIView!
    
    func set(protectedCard: ProtectedEntity<Fantasy.Card>) {
        protectedImageView.set(imageURL: protectedCard.entity.imageURL,
                               isProtected: protectedCard.isProtected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        protectedImageView.reset()
    }
    
}
