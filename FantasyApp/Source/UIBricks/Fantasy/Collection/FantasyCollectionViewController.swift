//
//  FantasyCollectionViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/21/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class FantasyCollectionViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: FantasyCollectionViewModel! = .init(router: .init(owner: self))
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Fantasy.Collection>>(configureCell: { [unowned self] (_, tableView, ip, x) in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.simpleCollectionCell,
                                                 for: ip)!
        
        cell.textLabel?.text = x.name
        cell.detailTextLabel?.text = "\(x.cardsCount) cards. Bought = \(x.isPurchased)"
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Fantasy.Collection.self)
            .subscribe(onNext: { [unowned self] x in
                self.viewModel.collectionTapped(collection: x)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

private extension FantasyCollectionViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
