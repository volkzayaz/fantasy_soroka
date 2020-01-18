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
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var parrotImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        versionLabel.text = viewModel.version
    }

    @IBAction func tapMadeWith(_ sender: Any) {
        guard let u = URL(string: R.string.localizable.fantasySettingsMadeWithMature()),
            UIApplication.shared.canOpenURL(u) else {
                return
        }

        UIApplication.shared.open(u, options: [:], completionHandler: nil)
    }

    @IBAction func tapHeart(_ sender: Any) {
    }
    
    @IBAction func tapParrot(_ sender: Any) {
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        viewModel.dismiss()
    }
}


//https://fantasyapp.com/en/blog/mature-love-basis-of-alternative-relationships/

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

        if indexPath.section == 4
            && indexPath.row == 0 {
            viewModel.logout()
        }
        
    }
    
}
