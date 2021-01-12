//
//  SubscriptionPlanStyle1View.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 02.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class SubscriptionPlanStyle1View: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stickerView: UIView!
    @IBOutlet private weak var stickerLabel: UILabel!
    @IBOutlet private weak var subscribeButton: UIButton!
    
    private let planType: SubscriptionPlanType
    private var subscription: () -> Void
    
    init(plan: SubscriptionPlan, frame: CGRect = .zero, subscription: @escaping () -> Void) {
        self.planType = plan.type
        self.subscription = subscription
        
        super.init(frame: frame)
        loadFromNib()
        
        titleLabel.text = plan.title
        subtitleLabel.text = plan.payment
        descriptionLabel.attributedText = plan.details
        subscribeButton.setTitle(plan.buttonTitle, for: .normal)
        
        stickerView.isHidden = plan.sticker == nil
        stickerLabel.text = plan.sticker
        
        switch planType {
        case .trial: stickerView.addBlueFantasyDiagonalGradient()
        case .offer: stickerView.addFantasyDiagonalGradient()
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.subscribeButton.removeGradient()
            self.subscribeButton.addFantasyGradient()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SubscriptionPlanStyle1View {
    
    @IBAction private func subscribe(_ sender: Any) {
        subscription()
    }
}
