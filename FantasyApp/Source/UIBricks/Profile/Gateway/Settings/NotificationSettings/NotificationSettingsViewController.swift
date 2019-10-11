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

class NotificationSettingsViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: NotificationSettingsViewModel! = NotificationSettingsViewModel(router: .init(owner: self))
    
    @IBOutlet weak var newMatchSwitch: UISwitch!
    @IBOutlet weak var newMessageSwitch: UISwitch!
    @IBOutlet weak var newFantasySwitch: UISwitch!
    
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
