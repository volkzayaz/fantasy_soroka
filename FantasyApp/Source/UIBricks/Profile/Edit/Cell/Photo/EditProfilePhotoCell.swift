//
//  EditProfilePhotoCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class EditProfilePhotoCell: UICollectionViewCell {
    
    var viewModel: ProfilePhotoViewModel! {
        didSet {
            
            viewModel.image
                .drive(photoView.rx.image)
                .disposed(by: rx.disposeBag)
            
            viewModel.deleteButtonHidden
                .drive(closeButton.rx.isHidden)
                .disposed(by: rx.disposeBag)
            
        }
    }
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        photoView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: Selector("selectImage")))
    }
    
    @IBAction func close(_ sender: Any) {
        viewModel.deletePhoto()
    }
    
    @objc func selectImage() {
        viewModel.pickPhoto()
    }
    
}
