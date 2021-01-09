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
    
    let models = [MonetizationModel(image: R.image.memberProfilesNew()!,
                                    title: R.string.localizable.monetizationX3NewProfilesTitle(),
                                    description: R.string.localizable.monetizationX3NewProfilesSubtitle()),
                  MonetizationModel(image: R.image.memberGlobalNew()!,
                                    title: R.string.localizable.monetizationGlobalModeTitle(),
                                    description: R.string.localizable.monetizationGlobalModeSubtitle()),
                  MonetizationModel(image: R.image.memberActiveCityNew()!,
                                    title: R.string.localizable.monetizationMemberActiveCityTitle(),
                                    description: R.string.localizable.monetizationMemberActiveCitySubtitle()),
                  MonetizationModel(image: R.image.memberAccessToDecksNew()!,
                                    title: R.string.localizable.monetizationAccessToAllDecksTitle(),
                                    description: R.string.localizable.monetizationAccessToAllDecksSubtitle()),
                  MonetizationModel(image: R.image.memberCardsNew()!,
                                    title: R.string.localizable.monetizationMemberX3Title(),
                                    description: R.string.localizable.monetizationMemberX3Subtitle()),
                  MonetizationModel(image: R.image.memberRoomsNew()!,
                                    title: R.string.localizable.monetizationMemberUnlimRoomsTitle(),
                                    description: R.string.localizable.monetizationMemberUnlimRoomsSubtitle()),
                  MonetizationModel(image: R.image.memberBadgeNew()!,
                                    title: R.string.localizable.monetizationMemberParrotTitle(),
                                    description: R.string.localizable.monetizationMemberParrotSubtitle()),
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = R.string.localizable.monetizationTitle()
        
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
        
        if appStateSlice.currentUser?.subscription.isSubscribed ?? false {
            return models.count + 1
        }
        else {
            return models.count + 2
        }
        
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
        
        normalShadowRadius = 10
        
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
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc))
        
        x.present(nav, animated: true, completion: nil)
        
        
    }
    
}

class SubscriptionUpdatingLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        appState.map { $0.currentUser?.subscription.isSubscribed ?? false }
            .map { $0 ? R.string.localizable.monetizationManageMembership() : R.string.localizable.monetizationGetClubMembership() }
            .drive(rx.text)
            .disposed(by: rx.disposeBag)
    }
    
}
