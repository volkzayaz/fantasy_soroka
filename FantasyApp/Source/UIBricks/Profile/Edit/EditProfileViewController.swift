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
                
            case .about(let x):
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.editProfileAboutCell,
                                                         for: ip)!
                
                cell.expandableTextView.text = x
                cell.viewModel = self.viewModel
                cell.tableView = tableView
                
                return cell
                
            case .attribute(let name, let value, _):
                
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: R.reuseIdentifier.attributeEditProfileCell,
                                         for: ip)!
                
                cell.valueLabel.text = name
                cell.attributeLabel.text = value
                
                return cell
                
            }
            
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].model
        })
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var publicPhotoCollectionView: ProfilePhotoCollectionView! {
        didSet {
            publicPhotoCollectionView.viewModel = viewModel
            publicPhotoCollectionView.isPublic = true
        }
    }
    
    @IBOutlet weak var privatePhotoCollectionView: ProfilePhotoCollectionView! {
        didSet {
            privatePhotoCollectionView.viewModel = viewModel
            privatePhotoCollectionView.isPublic = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Preview",
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(preview)),
        ]
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(VM.Model.self)
            .subscribe(onNext: { (x) in
                
                switch x {
                case .attribute(_, _, let editAction): editAction?()
                    
                case .about(_): break
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension EditProfileViewController: UIGestureRecognizerDelegate {

    @objc func preview() {
        viewModel.preview()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return  !(touch.view?.isDescendant(of: tableView) ?? false)
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
    
}
