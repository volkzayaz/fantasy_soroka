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

    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Community>>(
        configureCell: { [unowned self] (_, tableView, ip, x) in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teleportCell,
                                                     for: ip)!
            
            cell.textLabel?.text = x.name
            
            return cell
            
        })
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Community.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.selected(community: x)
            })
            .disposed(by: rx.disposeBag)
    }
    
}

private extension TeleportViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
