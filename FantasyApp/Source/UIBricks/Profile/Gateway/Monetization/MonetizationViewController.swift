//
//  MonetizationViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/26/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class MonetizationViewController: UIViewController {
    
    let models = [MonetizationModel(image: R.image.monMember()!,
                                    title: "Member Badge",
                                    description: "Get a badge stating that you support Fantasy's values of sexual mindfulness, openness, and exploration"),
                  MonetizationModel(image: R.image.monUnlimitedRooms()!,
                                    title: "Unlimited Rooms To Play",
                                    description: "Chat, play, and swipe to see mutual fantasies with as many people as you want"),
                  MonetizationModel(image: R.image.mon3XCards()!,
                                    title: "x3 New Fantasies Daily",
                                    description: "Discover more new fantasy cards every day"),
                  MonetizationModel(image: R.image.monScreenprotect()!,
                                    title: "ScreenProtect",
                                    description: "Protect your profile and rooms from being screenshotted or screenrecorded from other devices"),
                  MonetizationModel(image: R.image.monActiveCities()!,
                                  title: "Change Active City",
                                  description: "Switch your profile to other active cities to play with new people around the world"),
                  
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Membership"
        view.backgroundColor = R.color.goldenMember()!
        
        tableView.layer.cornerRadius = 20
        
    }
    
}

extension MonetizationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.monetizationCell, for: indexPath)!
        
        let model = models[indexPath.row]
        
        cell.iconImageView.image = model.image
        cell.titleTextLabel.text = model.title
        cell.descirpitonTextLabel.text = model.description
        
        cell.duplicateTitleView.text = model.title
        
        return cell
    }
    
}

struct MonetizationModel {
    let image: UIImage
    let title: String
    let description: String
}

class MonetizationCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var descirpitonTextLabel: UILabel!
    
    @IBOutlet weak var duplicateTitleView: UILabel!
    
    @IBOutlet weak var roundedView: UIView! {
        didSet {
            roundedView.backgroundColor = .white
            
            roundedView.layer.borderColor = R.color.goldenMember()!.cgColor
            roundedView.layer.borderWidth = 1
            roundedView.layer.cornerRadius = 16
            
        }
    }
    
}
