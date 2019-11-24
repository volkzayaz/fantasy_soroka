//
//  ChatHeaderCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

class ChatHeaderCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapOnAvatar")))
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var inviteLabel: UILabel!
    
    var viewModel: ChatViewModel!
    
    func setConnections(_ connections: Set<ConnectionRequestType>) {
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        
        connections
            .map { UIImageView(image: $0.outgoingRequestImage) }
            .forEach(stackView.addArrangedSubview)
        
    }
    
    func set(user: Room.Participant.UserSlice) {
        
        let str: NSString = "\(user.name) sent\nnew room request" as NSString
        
        let attributedString = NSMutableAttributedString(string: str as String, attributes: [
          .font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
          .foregroundColor: R.color.textBlackColor()!
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 211.0 / 255.0, green: 100.0 / 255.0, blue: 177.0 / 255.0, alpha: 1.0), range: str.range(of: user.name))
        
        inviteLabel.attributedText = attributedString
        
        ImageRetreiver.imageForURLWithoutProgress(url: user.avatarURL)
            .map { $0 ?? R.image.noPhoto()! }
            .drive(avatarImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
    }
    
    @objc func tapOnAvatar() {
        viewModel.presentInitiator()
    }
    
}
