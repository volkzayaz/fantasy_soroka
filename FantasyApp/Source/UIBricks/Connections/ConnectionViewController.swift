//
//  ConnectionViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class ConnectionViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: ConnectionViewModel! = ConnectionViewModel(router: .init(owner: self))
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.connectionRequestCell,
                                                 for: ip)!
        
        cell.textLabel?.text = x.bio.name
        
        return cell
        
    })
    
    
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet private weak var label: UILabel!
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.requests
            .map { [SectionModel(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    
        tableView.rx.modelSelected(User.self)
            .subscribe(onNext: { [unowned self] (x) in
                
                self.viewModel.show(user: x)
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewAppeared()
    }
    
}

private extension ConnectionViewController {
    
    @IBAction func dataSourceChanged(_ sender: UISegmentedControl) {
        viewModel.sourceChanged(source: sender.selectedSegmentIndex == 0 ? .incomming : .outgoing )
    }
    
}
