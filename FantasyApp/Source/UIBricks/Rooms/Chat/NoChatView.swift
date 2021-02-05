//
//  NoChatView.swift
//  FantasyApp
//
//  Created by Максим Сорока on 29.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class NoChatView: UIView {
    
    var vm: ChatViewModel!
  
    @IBOutlet weak var inviteButton: SecondaryButton! {
        didSet {
            inviteButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
        }
    }

    @IBAction func inviteButtonPressed(_ sender: Any) {
        vm.inviteButtonPressed()
    }
    
    
}
