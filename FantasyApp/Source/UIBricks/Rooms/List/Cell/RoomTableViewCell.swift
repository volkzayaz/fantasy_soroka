//
//  RoomTableViewCell.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift

class RoomTableViewCell: UITableViewCell {
    @IBOutlet private (set) var nameLabel: UILabel!
    @IBOutlet private (set) var timeLabel: UILabel!
    @IBOutlet private (set) var lastMessageLabel: UILabel!
    @IBOutlet private var separator: UIView!
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    
    func set(model: Room) {
        
        guard let peer = model.peer.userSlice else {
            return;
        }
        
        nameLabel.text = "\(peer.name)"
        timeLabel.text = model.lastMessage?.createdAt.toTimeAgoString() ?? ""
        
        if let x = model.lastMessage {
            lastMessageLabel.text = x.typeDescription(peer: peer.name)
        }
        else {
            lastMessageLabel.text = R.string.localizable.roomListNewRoom()
        }
        
        unreadCounterLabel.text = "\(model.unreadCount ?? 0)"
        unreadCounterLabel.isHidden = model.unreadCount == 0
        
        ImageRetreiver.imageForURLWithoutProgress(url: peer.avatarURL)
            .map { $0 ?? R.image.noPhoto() }
            .drive(roomImageView.rx.image)
            .disposed(by: disposeBag)
        
    }
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
}

private extension RoomTableViewCell {
    func configure() {
        selectionStyle = .none
        separator.backgroundColor = UIColor.basicGrey.withAlphaComponent(0.18)
        nameLabel.textColor = .fantasyBlack
        nameLabel.font = .boldFont(ofSize: 15)
        lastMessageLabel.textColor = .fantasyBlack
        lastMessageLabel.font = .regularFont(ofSize: 15)
        timeLabel.textColor = .basicGrey
        timeLabel.font = .regularFont(ofSize: 12)
    }
}
