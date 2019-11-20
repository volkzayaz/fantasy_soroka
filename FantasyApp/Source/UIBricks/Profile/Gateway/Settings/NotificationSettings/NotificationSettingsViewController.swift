//
//  NotificationSettingsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class NotificationSettingsViewController: UITableViewController, MVVM_View {
    
    lazy var viewModel: NotificationSettingsViewModel! = NotificationSettingsViewModel(router: .init(owner: self))
    
    @IBOutlet weak var newMatchSwitch: UISwitch!{
        didSet {
            newMatchSwitch.onTintColor = R.color.textPinkColor()
        }
    }
    @IBOutlet weak var newMessageSwitch: UISwitch!{
        didSet {
            newMessageSwitch.onTintColor = R.color.textPinkColor()
        }
    }
    @IBOutlet weak var newFantasySwitch: UISwitch!{
        didSet {
            newFantasySwitch.onTintColor = R.color.textPinkColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newMatchSwitch.isOn = viewModel.currentSettings.newMatch
        newMessageSwitch.isOn = viewModel.currentSettings.newMessage
        newFantasySwitch.isOn = viewModel.currentSettings.newFantasyMatch
    }
}

private extension NotificationSettingsViewController {
    
    @IBAction func newMatchSettingsChanged(_ sender: Any) {
        viewModel.changeMatchSettings(state: newMatchSwitch.isOn)
    }
    
    @IBAction func newMessageSettingsChanged(_ sender: Any) {
        viewModel.changeMessageSettings(state: newMessageSwitch.isOn)
    }
    
    @IBAction func newFantasyMatchSettingsChanged(_ sender: Any) {
        viewModel.changeFantasyMatchSettings(state: newFantasySwitch.isOn)
    }
    
}

extension NotificationSettingsViewController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = ProfileSettingsHeaderView.instance

        switch section {
        case 0: v.setText("Push")

        default: v.setText(" ")
        }

        return v
    }
}
