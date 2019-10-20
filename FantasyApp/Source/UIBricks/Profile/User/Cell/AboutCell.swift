//
//  AboutCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class UserProfileAboutCell: UITableViewCell {
    
    @IBOutlet weak var sexualityGradientView: SexualityGradientView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

class UserProfileAnswerCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
}

class UserProfileBioCell: UITableViewCell {
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    
}

class UserProfileBasicCell: UITableViewCell {
    
    @IBOutlet weak var basicLabel: UILabel!
    @IBOutlet var goldMemberBadge: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var likeIndicatorImageView: UIImageView!
    
}
