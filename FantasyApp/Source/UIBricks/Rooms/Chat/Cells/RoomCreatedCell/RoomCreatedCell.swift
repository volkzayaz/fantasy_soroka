//
//  RoomCreatedCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomCreatedCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    func setParticipants(left: Room.Participant.UserSlice,
                         right: Room.Participant.UserSlice) {
        
        ImageRetreiver.imageForURLWithoutProgress(url: left.avatarURL)
            .map { $0 ?? R.image.noPhoto() }
            .drive(leftImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        ImageRetreiver.imageForURLWithoutProgress(url: right.avatarURL)
            .map { $0 ?? R.image.noPhoto() }
            .drive(rightImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
    }
    
}
