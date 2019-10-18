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
