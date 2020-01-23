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
    
    func set(model: Room) {
        
        let participant: Room.Participant = model.peer
        
        nameLabel.text = "\(participant.userSlice.name)"// (\(model.unreadMessages))"
        timeLabel.text = model.lastMessage?.createdAt.toTimeAgoString() ?? ""
        lastMessageLabel.text = model.lastMessage?.text ?? "new room"
        
        ImageRetreiver.imageForURLWithoutProgress(url: participant.userSlice.avatarURL)
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
