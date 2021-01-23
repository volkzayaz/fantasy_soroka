//
//  PrimarySubscriptionPlanStyle2View.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 23.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class PrimarySubscriptionPlanStyle2View: UIView {

    @IBOutlet private weak var subscribeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var subscription: () -> Void
    
    init(plan: SubscriptionPlan, frame: CGRect = .zero, subscription: @escaping () -> Void) {
        self.subscription = subscription
        
        super.init(frame: frame)
        loadFromNib()
        
        subscribeButton.setTitle(plan.buttonTitle, for: .normal)
        
        let description = NSMutableAttributedString(string: plan.description)
        if let range = plan.description.range(of: plan.dailyPayment) {
            description.addAttributes([.font : UIFont.boldFont(ofSize: 15)], range: plan.description.nsRange(from: range))
        }
        
        if let baseProductDetails = plan.baseProductDetails, let range = plan.description.range(of: baseProductDetails) {
            description.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue], range: plan.description.nsRange(from: range))
        }
        
        descriptionLabel.attributedText = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PrimarySubscriptionPlanStyle2View {
    
    @IBAction func subscribe(_ sender: Any) {
        subscription()
    }
}
