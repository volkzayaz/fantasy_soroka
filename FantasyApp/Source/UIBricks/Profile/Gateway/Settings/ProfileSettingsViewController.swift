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
    
    @IBOutlet weak var freeSubscriptionSwitch: UISwitch!{
        didSet {
            freeSubscriptionSwitch.onTintColor = R.color.textPinkColor()
        }
    }
    
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

    @IBAction func done(_ sender: UIBarButtonItem) {
        viewModel.dismiss()
    }
}

extension ProfileSettingsViewController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = ProfileSettingsHeaderView.instance
        
        switch section {
        case 0: v.setText("Account")
        case 1: v.setText("Rooms")
        case 2: v.setText("Subscriptions")
        case 3: v.setText("Support")

        default: v.setText(" ")
        }

        return v
    }
    
    override internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 2 && indexPath.row == 1 {
            viewModel.restorePurchases()
        }

        if indexPath.section == 3 && indexPath.row == 0 {
            viewModel.helpSupport()
        }

        if indexPath.section == 3 && indexPath.row == 1 {
            viewModel.legal()
        }

        if indexPath.section == 3 && indexPath.row == 2 {
            viewModel.communityRules()
        }

        if indexPath.section == 3 && indexPath.row == 3 {
            viewModel.rateUs()
        }

        if indexPath.section == 4 {
              viewModel.deleteAccount()
          }
        if indexPath.section == 5 {
            viewModel.logout()
        }
        
    }
    
}
