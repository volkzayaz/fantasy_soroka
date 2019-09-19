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
    @IBOutlet weak var locationMessageLabel: UILabel!
    @IBOutlet weak var profilesTableView: UITableView!
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Profile>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSearchCell,
                                                 for: ip)!
        
        cell.textLabel?.text = x.bio.name
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
                
                [self.profilesTableView, self.timeEndedLabel, self.locationMessageLabel]
                    .forEach { $0?.isHidden = true }
                
                switch mode {
                case .profiles:
                    self.profilesTableView.isHidden = false
                    
                case .overTheLimit:
                    self.timeEndedLabel.isHidden = false
                    
                case .noLocationPermission:
                    self.locationMessageLabel.isHidden = false
                    self.locationMessageLabel.text = "Can you share your location? We really need it"
                    
                case .absentCommunity(let nearestCity):
                    self.locationMessageLabel.isHidden = false
                    if let nearestCity = nearestCity {
                        self.locationMessageLabel.text = "Fantasy is not yet available at \(nearestCity). Stay tuned, we'll soon be there"
                    }
                    else {
                        self.locationMessageLabel.text = "We can't figure out where are you at the moment. Feel free to send us your City at fantasyapp@email.com. Or use teleport"
                    }
                    
                case .noSearchPreferences:
                    self.locationMessageLabel.isHidden = false
                    self.locationMessageLabel.text = "Before we search, set your searching preferences"
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension DiscoverProfileViewController {

    @objc func presentFilter() {
        viewModel.presentFilter()
    }
    
}
