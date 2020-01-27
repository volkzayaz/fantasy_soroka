//
//  RoomCreatedCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class EventCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    
    var eventImage: UIImage! {
        didSet {
            leftImageView.image = eventImage
        }
    }
    
    var event: String! {
        didSet {
            eventLabel.text = event
        }
    }

}
