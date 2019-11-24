//
//  AcceptRejectCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/24/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class AcceptRejectCell: UITableViewCell {
    
    var viewModel: ChatViewModel!
    
    @IBOutlet weak var rejectButton: UIButton! {
        didSet {
            rejectButton.addTarget(self, action: #selector(AcceptRejectCell.reject), for: .touchUpInside)
            rejectButton.backgroundColor = .clear
            rejectButton.layer.borderColor = UIColor(fromHex: 0xd364b1).cgColor
            rejectButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var acceptButton: UIButton! {
        didSet {
            acceptButton.addTarget(self, action: #selector(AcceptRejectCell.accept), for: .touchUpInside)
            acceptButton.backgroundColor = .clear
            acceptButton.addFantasyGradient(roundCorners: true)
        }
    }
    
    @objc func reject() {
        viewModel.rejectRequest()
    }
    
    @objc func accept() {
        viewModel.acceptRequest()
    }
    
}
