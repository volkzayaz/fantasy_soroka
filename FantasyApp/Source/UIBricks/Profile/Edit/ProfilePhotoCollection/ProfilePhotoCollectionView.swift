//
//  ProfilePhotoCollectionView.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class ProfilePhotoCollectionView: UICollectionView, UICollectionViewDataSource {
    
    var isPublic: Bool!
    var viewModel: EditProfileViewModel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("ProfilePhotos supports only static 6 itemed flow layouts")
        }
        
        layout.itemSize = .init(width: frame.size.height, height: frame.size.height)
        layout.minimumInteritemSpacing = 10
        
        dataSource = self
        
        register(R.nib.editProfilePhotoCell)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.editProfilePhotoCell,
                                                      for: indexPath)!
        
        cell.viewModel = .init(router: viewModel.profilePhotoRouter(for: cell),
                               number: indexPath.row,
                               isPublic: isPublic)
        
        return cell
    }

}
