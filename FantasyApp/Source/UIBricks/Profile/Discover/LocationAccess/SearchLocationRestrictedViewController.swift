//
//  SearchLocationRestrictedViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 25.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class SearchLocationRestrictedViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = R.string.localizable.searchLocationTitle()
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = R.string.localizable.searchLocationDescription()
        }
    }

    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.setTitle(R.string.localizable.searchLocationGoToSettings(), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addFantasyRoundedCorners()
    }

    @IBAction func settings(_ sender: Any) {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
