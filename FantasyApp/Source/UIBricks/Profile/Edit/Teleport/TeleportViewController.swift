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

    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TeleportViewModel.Data>>(
        configureCell: { [unowned self] (_, tableView, ip, x) in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teleportCell,
                                                     for: ip)!
            
            switch x {
            case .community(let communiy):
                cell.textLabel?.text = communiy.name
                
            case .location:
                cell.textLabel?.text = "Automaticly based on location"
                
            }
            
            return cell
            
        })
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(TeleportViewModel.Data.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.selected(data: x)
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
