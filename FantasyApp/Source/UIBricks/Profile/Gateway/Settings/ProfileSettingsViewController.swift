//
//  ProfileSettingsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ProfileSettingsViewController: UITableViewController, MVVM_View {
    
    lazy var viewModel: ProfileSettingsViewModel! = ProfileSettingsViewModel(router: .init(owner: self))
    
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet private weak var label: UILabel!
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         *  Set up any bindings here
         *  viewModel.labelText
         *     .drive(label.rx.text)
         *     .addDisposableTo(rx_disposeBag)
         */
        
    }
    
}

extension ProfileSettingsViewController {
    
    override internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 5 {
            viewModel.logout()
        }
        
        if indexPath.section == 4 {
            viewModel.deleteAccount()
        }

        if indexPath.section == 3 && indexPath.row == 1 {
            viewModel.restorePurchases()
        }
        
    }
    
}
