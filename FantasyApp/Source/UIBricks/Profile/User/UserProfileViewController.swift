//
//  UserProfileViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class UserProfileViewController: UIViewController, MVVM_View {
    
    var viewModel: UserProfileViewModel!
    
    @IBOutlet weak var indicatorStackView: UIStackView! {
        didSet {
            indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let layout = photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = photosCollectionView.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        for i in viewModel.photos.enumerated() {
            let x = UIView()
            x.backgroundColor = i.offset == 0 ? .red : .green
            
            indicatorStackView.addArrangedSubview(x)
        }
        
    }
    
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = photosCollectionView.indexPathsForVisibleItems.first?.row else {
            return
        }
        
        indicatorStackView.subviews.enumerated().forEach {
            $0.element.backgroundColor = $0.offset == index ? .red : .green
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePhotoCell, for: indexPath)!
        
        cell.set(photo: viewModel.photos[indexPath.row])
        
        return cell
    }
    
}

extension UserProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = viewModel.sections[indexPath.section]
        
        switch section {
        case .basic(let x):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileBasicCell, for: indexPath)!
            
            cell.textLabel?.text = x
            
            return cell
            
        case .about(let x):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.editProfileAboutCell, for: indexPath)!
            
            cell.textLabel?.text = x
            
            return cell
            
        case .extended(let x):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileExtendedCell, for: indexPath)!
            
            cell.textLabel?.text = x.joined(separator: "\n")
            
            return cell
            
        case .fantasy(let x):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileFantasyCell, for: indexPath)!
            
            cell.textLabel?.text = x
            
            return cell
            
        }
        
    }
    
}
