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
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var protectedImageView: SSKProtectedImageView! {
        didSet {
            protectedImageView.resizeMode = .scaleAspectFill
        }
    }
    
    var disposeBag = DisposeBag()
    
    func setCard(fantasy: Fantasy.Card) {

        ImageRetreiver.imageForURLWithoutProgress(url: fantasy.imageURL)
            .drive(onNext: { [unowned self] x in
                
                if appStateSlice.currentUser?.subscription.isSubscribed == true {
                    self.protectedImageView.image = x
                } else {
                    self.cardImageView.image = x
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardImageView.image = nil
        protectedImageView.image = nil
        
        disposeBag = DisposeBag()
    }
    
}
