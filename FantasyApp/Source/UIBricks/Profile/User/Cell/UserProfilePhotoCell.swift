//
//  UserProfilePhotoCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

class UserProfilePhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stubCell: UILabel! {
        didSet {
            stubCell.isHidden = true
        }
    }
    
    var disposeBag = DisposeBag()
    
    func set(photo: UserProfileViewModel.Photo) {
        
        switch photo {
        case .nothing:
            imageView.image = R.image.noPhoto()
        
        case .url(let url):
            ImageRetreiver.imageForURLWithoutProgress(url: url)
                .map { $0 ?? R.image.errorPhoto() }
                .drive(imageView.rx.image)
                .disposed(by: disposeBag)
            
        case .privateStub(let x):
            stubCell.isHidden = false
            stubCell.text = "\(x) more photos availabel after you match"
            
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        stubCell.isHidden = true
        disposeBag = DisposeBag()
    }
    
}
