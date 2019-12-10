//
//  RoomNotificationSettingsViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomNotificationSettingsViewController: UIViewController, MVVM_View {
    var viewModel: RoomNotificationSettingsViewModel!

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var separator: UIView!
    @IBOutlet private var newMessageLabel: UILabel!
    @IBOutlet private var newMessageSwitch: UISwitch!
    @IBOutlet private var newCommonFantasyLabel: UILabel!
    @IBOutlet private var newCommonFantasySwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension RoomNotificationSettingsViewController {
    func configure() {
        view.addFantasyGradient()
        
        titleLabel.text = R.string.localizable.roomNotificationSettingsPushTitle()
        titleLabel.font = .boldFont(ofSize: 15)
        titleLabel.textColor = .fantasyBlack

        newMessageLabel.text = R.string.localizable.roomNotificationSettingsNewMessages()
        newMessageLabel.font = .regularFont(ofSize: 15)
        newMessageLabel.textColor = .fantasyBlack

        newCommonFantasyLabel.text = R.string.localizable.roomNotificationSettingsNewCommonFantasies()
        newCommonFantasyLabel.font = .regularFont(ofSize: 15)
        newCommonFantasyLabel.textColor = .fantasyBlack

        separator.backgroundColor = .fantasySeparator

        newMessageSwitch.onTintColor = .fantasyPink
        newMessageSwitch.isOn = viewModel.currentSettings.newFantasyMatch

        newCommonFantasySwitch.onTintColor = .fantasyPink
        newCommonFantasySwitch.isOn = viewModel.currentSettings.newMessage
    }

    @IBAction func newCommonFantasySettingsChanged(_ sender: Any) {
        viewModel.changeCommonFantasySettings(state: newCommonFantasySwitch.isOn)
    }

    @IBAction func newMessageSettingsChanged(_ sender: Any) {
        viewModel.changeMessageSettings(state: newMessageSwitch.isOn)
    }
}
