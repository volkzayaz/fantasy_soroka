//
//  TeleportViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class TeleportViewController: UIViewController, MVVM_View {
    
    var viewModel: TeleportViewModel!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, TeleportViewModel.Data>>(animationConfiguration: .init(insertAnimation: .left, reloadAnimation: .automatic, deleteAnimation: .right),
        configureCell: { [unowned self] (_, tableView, ip, x) in
            
            switch x {
            case .community(let communiy):
            
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teleportCommunityCell,
                                                         for: ip)!
                
                cell.textLabel?.text = communiy.name
                
                return cell
                
            case .location(let title, let subtitle, let isSelected, let icon, _):
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teleportCurrentCell,
                                                         for: ip)!
                
                cell.locationNameLabel.text = title
                cell.countryNameLabel.text = subtitle
                cell.indicatorImageView.image = icon
                cell.tickButton.isSelected = isSelected
                
                return cell
                
            case .country(let country, let cityCount):
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teleportCountryCell,
                                                         for: ip)!
                
                cell.textLabel?.text = country
                cell.detailTextLabel?.text = "\(cityCount) Cities"
            
                return cell
            }
            
        })
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var activeCityHeaderView: UIView!
    @IBOutlet weak var teleportToBadge: UIImageView!
    @IBOutlet weak var teleportToLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Teleport"
        
        navigationItem.leftBarButtonItem = .init(image: R.image.back()!, style: .plain,
                                                 target: self, action: #selector(back))
    
        view.addFantasyGradient()
        
        tableView.estimatedSectionHeaderHeight = 84
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(TeleportViewModel.Data.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.selected(data: x)
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tv = tableView] (x) in
                tv?.deselectRow(at: x, animated: true)
            })
            .disposed(by: rx.disposeBag)
        viewModel.upgradeButtonHidden
            .drive(teleportToBadge.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension TeleportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 82 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            return self.activeCityHeaderView
        }
        
        return nil
    }
    
    @objc func back() {
        viewModel.back()
    }
    
}
