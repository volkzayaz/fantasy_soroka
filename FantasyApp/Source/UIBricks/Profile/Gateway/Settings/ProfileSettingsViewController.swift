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
    
    @IBOutlet weak var freeSubscriptionSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if RELEASE
        freeSubscriptionSwitch.isHidden = true
        #endif
        
        freeSubscriptionSwitch.isOn = SettingsStore.freeSubscriptionSwitch.value
        
    }
    
    @IBAction func freeSubscriptionSwitchChanged(_ sender: UISwitch) {
        SettingsStore.freeSubscriptionSwitch.value = sender.isOn
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

        if indexPath.section == 2 && indexPath.row == 1 {
            viewModel.restorePurchases()
        }
        
    }
    
}
