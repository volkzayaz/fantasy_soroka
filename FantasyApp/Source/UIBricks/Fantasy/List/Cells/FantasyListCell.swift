//
//  FantasyListCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

class FantasyListCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func setCard(fantasy: Fantasy.Card) {
    
        ImageRetreiver.imageForURLWithoutProgress(url: fantasy.imageURL)
            .drive(cardImageView.rx.image)
            .disposed(by: rx.disposeBag)    
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardImageView.image = nil
        
        disposeBag = DisposeBag()
    }
    
}
