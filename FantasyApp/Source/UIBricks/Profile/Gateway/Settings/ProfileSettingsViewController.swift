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
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        versionLabel.text = viewModel.version
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        viewModel.dismiss()
    }
}

extension ProfileSettingsViewController {


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = ProfileSettingsHeaderView.instance
        
        switch section {
        case 0: v.setText(R.string.localizable.fantasySettingsSectionAccount())
        //case 1: v.setText(R.string.localizable.fantasySettingsSectionRooms())
        case 1: v.setText(R.string.localizable.fantasySettingsSectionSubscriptions())
        case 2: v.setText(R.string.localizable.fantasySettingsSectionSupport())

        default: v.setText(" ")
        }

        return v
    }
    
    override internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 0 {
            viewModel.restorePurchases()
        }

        if indexPath.section == 2 && indexPath.row == 0 {
            viewModel.helpSupport()
        }

        if indexPath.section == 2 && indexPath.row == 1 {
            viewModel.privacyPolicy()
        }
        
        if indexPath.section == 2 && indexPath.row == 2 {
            viewModel.termsAndConditions()
        }

        if indexPath.section == 2 && indexPath.row == 3 {
            viewModel.communityRules()
        }

        if indexPath.section == 2 && indexPath.row == 4 {
            viewModel.rateUs()
        }

        if indexPath.section == 3 {
              viewModel.deleteAccount()
          }
        if indexPath.section == 4 {
            viewModel.logout()
        }
        
    }
    
}
