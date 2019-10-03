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
import RxDataSources

class UserProfileViewController: UIViewController, MVVM_View {
    
    var viewModel: UserProfileViewModel!
    
    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, UserProfileViewModel.Photo>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePhotoCell, for: ip)!
        
        cell.set(photo: x)
        
        return cell
        
    })
    
    @IBOutlet weak var indicatorStackView: UIStackView! {
        didSet {
            indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var relationStatusLabel: UILabel!
    @IBOutlet weak var relationActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let layout = photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = photosCollectionView.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        viewModel.photos
            .do(onNext: { [weak self] (data) in
                
                self?.indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
                
                for i in data.first!.items.enumerated() {
                    let x = UIView()
                    x.backgroundColor = i.offset == 0 ? .red : .green
                    
                    self?.indicatorStackView.addArrangedSubview(x)
                }

            })
            .drive(photosCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.relationLabel
            .drive(relationStatusLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.relationActionTitle
            .drive(relationActionButton.rx.title(for: .normal))
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension UserProfileViewController {
    
    @IBAction func relationAction(_ sender: Any) {
        viewModel.relationAction()
    }
    
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = photosCollectionView.indexPathsForVisibleItems.first?.row else {
            return
        }
        
        indicatorStackView.subviews.enumerated().forEach {
            $0.element.backgroundColor = $0.offset == index ? .red : .green
        }
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileAboutCell, for: indexPath)!
            
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
