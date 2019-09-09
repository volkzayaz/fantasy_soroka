//
//  DiscoverProfileViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class DiscoverProfileViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: DiscoverProfileViewModel! = DiscoverProfileViewModel(router: .init(owner: self))
    
    @IBOutlet weak var timeEndedLabel: UILabel!
    @IBOutlet weak var profilesTableView: UITableView!
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Profile>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSearchCell,
                                                 for: ip)!
        
        cell.textLabel?.text = x.profile.bio.name
        //cell.detailTextLabel?.text = "\(x.cards.count) cards"
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .done,
                                                            target: self, action: "presentFilter")
        
        viewModel.profiles
            .map { [SectionModel(model: "", items: $0)] }
            .drive(profilesTableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.timeLeftText
            .drive(timeEndedLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        profilesTableView.rx.willDisplayCell
            .subscribe(onNext: { [weak view = profilesTableView, weak self] (_, ip) in
                guard let model: Profile = try? view?.rx.model(at: ip) else {
                    return
                }
                
                self?.viewModel.profileSwiped(profile: model)
            })
            .disposed(by: rx.disposeBag)
        
        profilesTableView.rx.modelSelected(Profile.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.profileSelected(x)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.mode
            .drive(onNext: { [unowned self] (mode) in
                self.profilesTableView.isHidden = mode == .overTheLimit
                self.timeEndedLabel.isHidden = mode == .profiles
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension DiscoverProfileViewController {

    @objc func presentFilter() {
        viewModel.presentFilter()
    }
    
}
