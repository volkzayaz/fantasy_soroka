//
//  EditProfileViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class EditProfileViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: EditProfileViewModel! = EditProfileViewModel(router: .init(owner: self))
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, VM.Model>>(
        configureCell: { [unowned self] (_, tableView, ip, x) in
            
            switch x {
                
            case .expandable(let text, let placeholder, let maybeTitle, let action):
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.editProfileExpandableCell,
                                                         for: ip)!
                
                cell.expandableTextView.text = text
                cell.expandableTextView.placeholder = placeholder
                cell.action = action
                cell.tableView = tableView
                
                if let title = maybeTitle {
                    cell.stackTitleLabel.text = title
                } else {
                    cell.dropTitle()
                }
                
                return cell
                
            case .attribute(let name, let value, let image, let maybeAction):
                
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: R.reuseIdentifier.attributeEditProfileCell,
                                         for: ip)!
                
                cell.attributeLabel.text = name
                cell.valueLabel.text = value
                cell.indicatorImage.image = image
                cell.lockImage.isHidden = maybeAction != nil
                cell.valueLabel.isHidden = maybeAction == nil
                
                return cell
                
            case .footer:
                return tableView
                .dequeueReusableCell(withIdentifier: R.reuseIdentifier.editProfileFooterCell,
                                     for: ip)!
                
                
            }
            
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].model
        })
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var photoContainerView: UIView! {
        didSet {
            photoContainerView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var publicPhotoCollectionView: ProfilePhotoCollectionView! {
        didSet {
            publicPhotoCollectionView.viewModel = viewModel
            publicPhotoCollectionView.isPublic = true
            publicPhotoCollectionView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var privatePhotoCollectionView: ProfilePhotoCollectionView! {
        didSet {
            privatePhotoCollectionView.viewModel = viewModel
            privatePhotoCollectionView.isPublic = false
            privatePhotoCollectionView.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        
        title = "Profile"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Preview",
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(preview)),
        ]
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tv = tableView] (x) in
                tv?.deselectRow(at: x, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(VM.Model.self)
            .subscribe(onNext: { (x) in
                
                switch x {
                case .attribute(_, _, _, let editAction): editAction?()
                    
                case .expandable(_), .footer: break
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        let height = photoContainerView.bounds.size.height
        
        tableView.rx.contentOffset
            .map { [unowned self] offset in
                
                let inset: CGFloat = self.view.safeAreaInsets.top
                let containerHeight: CGFloat = height
                
                return CGPoint(x: offset.x, y: max(-1 * (offset.y - inset - containerHeight), inset))
            }
            .subscribe(onNext: { [unowned self] (x) in
                
                self.backgroundView.frame = .init(origin: x,
                                                  size: self.tableView.contentSize)
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        ///just rxing into contentOffset observable
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + 1)
    }
    
}

extension EditProfileViewController: UIScrollViewDelegate {
    
    @objc func preview() {
        viewModel.preview()
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
    
}
