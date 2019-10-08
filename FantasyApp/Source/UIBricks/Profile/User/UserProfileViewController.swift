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
    
    lazy var sectionsTableDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, UserProfileViewModel.Section>>(configureCell: { [unowned self] (_, tv, ip, section) in
        
        switch section {
        case .basic(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileBasicCell, for: ip)!
            
            cell.textLabel?.text = x
            
            return cell
            
        case .about(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileAboutCell, for: ip)!
            
            cell.textLabel?.text = x
            
            return cell
            
        case .extended(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileExtendedCell, for: ip)!
            
            cell.textLabel?.text = x.joined(separator: "\n")
            
            return cell
            
        case .fantasy(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileFantasyCell, for: ip)!
            
            cell.textLabel?.text = x
            
            return cell
            
        }
        
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
        
        viewModel.sections
            .map { $0.map { AnimatableSectionModel(model: $0.identity, items: [$0]) } }
            .drive(profileTableView.rx.items(dataSource: sectionsTableDataSource))
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
