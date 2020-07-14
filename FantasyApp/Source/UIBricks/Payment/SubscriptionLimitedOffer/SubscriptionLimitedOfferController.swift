//
//  SubscriptionLimitedOfferController.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 12.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SubscriptionLimitedOfferController: UITableViewController, MVVM_View {
    
    @IBOutlet weak var subscribeButton: SecondaryButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveView: UIView!
    
    var viewModel: SubscriptionLimitedOfferViewModel!
    var plan: SubscriptionLimitedOfferViewModel.Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = R.string.localizable.subscriptionLimitedOfferNavigationTitle()
        
        roundedView.clipsToBounds = true
        roundedView.layer.cornerRadius = 20
        priceView.clipsToBounds = true
        priceView.layer.cornerRadius = 20
        
        saveView.backgroundColor = .clear;
        saveView.addFantasySubscriptionGradient(radius: true)
        
        roundedView.addFantasyRoundedCorners()
        navigationController?.view.addFantasySubscriptionGradient()
        edgesForExtendedLayout = []
        
        viewModel.offer.drive(onNext: { [unowned self] x in
            guard let plan = x else { return }
            
            Analytics.report(Analytics.Event.PurchaseInterest(context: .subscriptionOffer, itemName: plan.analyticsName, discount: String(plan.savePercent)))
            
            self.saveLabel.text = R.string.localizable.subscriptionLimitedOfferSave(plan.savePercent)
            self.plan = plan
            self.nameLabel.text = plan.name
            self.priceLabel.attributedText = plan.price
        })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func subscribe(_ sender: Any) {
        guard let plan = self.plan else { return }

        viewModel.subscribe(plan: plan)
    }
    
    @IBAction func cancel(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("screenCancel"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}
