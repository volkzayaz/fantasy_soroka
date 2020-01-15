//
//  MonetizationViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/26/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

class MonetizationViewController: UIViewController {
    
    let models = [MonetizationModel(image: R.image.memberUnlimRooms()!,
                                    title: "Unlimited Rooms To Play",
                                    description: "Chat, play, and swipe to see mutual fantasies with as many people as you want"),
                  MonetizationModel(image: R.image.memberX3()!,
                                    title: "x3 New Fantasies Daily",
                                    description: "Discover more new fantasy cards every day"),
                  MonetizationModel(image: R.image.memberScreenProtect()!,
                                    title: "ScreenProtect",
                                    description: "Protect your profile and rooms from being screenshotted or screenrecorded from other devices"),
                  MonetizationModel(image: R.image.memberActiveCity()!,
                                  title: "Change Active City",
                                  description: "Switch your profile to other active cities to play with new people around the world"),
                  MonetizationModel(image: R.image.memberParrot()!,
                                    title: "Member Badge",
                                    description: "Get a badge stating that you support Fantasy's values of sexual mindfulness, openness, and exploration"),
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Club Membership"
        
        appState.map { $0.currentUser?.subscription.isSubscribed ?? false }
            .drive(onNext: { [weak v = view] (isSubscribed) in
                
                if let l = v?.layer.sublayers?.first as? CAGradientLayer {
                    l.removeFromSuperlayer()
                }
                
                isSubscribed ?
                    v?.addFantasySubscriptionGradient() :
                    v?.addFantasyTripleGradient()
                
            })
            .disposed(by: rx.disposeBag)
        
        
        
        tableView.layer.cornerRadius = 20
        
    }
    
}

extension MonetizationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.headerCell, for: indexPath)!
        } else if indexPath.row == models.count + 1 {
            return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.membershipSubscribe, for: indexPath)!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.monetizationCell, for: indexPath)!
        
        let model = models[indexPath.row - 1]
        
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
            
            roundedView.layer.borderColor = R.color.textPinkColor()!.cgColor
            roundedView.layer.borderWidth = 1
            roundedView.layer.cornerRadius = 16
            
        }
    }
    
}

class MonetizationSubscribeButton: SecondaryButton {

    @IBOutlet unowned var presenter: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTarget(self, action: Selector("subscribe"), for: .touchUpInside)
    }
    
    @objc func subscribe() {
        
        guard let x = presenter else {
            fatalErrorInDebug("You should set `MonetizationSubscribeButton.presenter = myViewController` before clicking the button")
            return
        }
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: .screenProtect)
        
        x.present(nav, animated: true, completion: nil)
        
        
    }
    
}

class SubscriptionUpdatingLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        appState.map { $0.currentUser?.subscription.isSubscribed ?? false }
            .map { $0 ? "Manage Membership" : "Get Club Membership" }
            .drive(rx.text)
            .disposed(by: rx.disposeBag)
    }
    
}
