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
    
    func set(model room: Chat.Room) {
        
        nameLabel.text = room.roomName
        timeLabel.text = (room.details?.updatedAt ?? Date()).toTimeAgoString()
        lastMessageLabel.text = room.details?.lastMessage ?? ""

//            ImageRetreiver.imageForURLWithoutProgress(url: connection.user.bio.photos.avatar.url)
//            .map { $0 ?? R.image.noPhoto() }
//            .drive(avatarImageView.rx.image)
//            .disposed(by: bag)
        
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
