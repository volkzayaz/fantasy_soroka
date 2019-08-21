//
//  FantasySearchViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class FantasySearchViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasySearchViewModel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FantasySearchViewModel.Model>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.regularFantasySearch,
                                                 for: ip)!
        
        cell.textLabel?.text = "\(x.card.name) + isBlured = \(x.isBlurred)"
        
        return cell
            
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        searchField.rx.text
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.searchQueryChanged(x: x ?? "")
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(FantasySearchViewModel.Model.self)
            .subscribe(onNext: { [unowned self] x in
                self.viewModel.modelTapped(model: x)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

private extension FantasySearchViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
