//
//  FantasyListViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class FantasyListViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyListViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Fantasy.Card>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.regularFantasyCell,
                                                 for: ip)!
        
        cell.textLabel?.text = x.text
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Fantasy.Card.self)
            .subscribe(onNext: { [unowned self] x in
                self.viewModel.cardTapped(card: x)
            })
            .disposed(by: rx.disposeBag)
    }
    
}

private extension FantasyListViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
