//
//  SubscriptionPlanStyle2View.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 23.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class SubscriptionPlanStyle2View: UIView {

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
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
        
        let details = NSMutableAttributedString(string: plan.details)
        if let range = plan.details.range(of: plan.dailyPayment) {
            details.addAttributes([.font : UIFont.boldFont(ofSize: 12)], range: plan.details.nsRange(from: range))
        }
        
        if let baseProductDetails = plan.baseProductDetails, let range = plan.details.range(of: baseProductDetails) {
            details.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue], range: plan.details.nsRange(from: range))
        }
        
        detailsLabel.attributedText = details
        subscribeButton.setTitle(plan.buttonTitle, for: .normal)
        
        stickerView.isHidden = plan.sticker == nil
        stickerLabel.text = plan.sticker
        
        switch planType {
        case .trial: stickerView.addBlueFantasyDiagonalGradient()
        case .special: stickerView.addFantasyDiagonalGradient()
        default:
            break
        }
        
        setUpShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.updateShadowFrame()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SubscriptionPlanStyle2View {
    
    func setUpShadow() {
        layer.shadowColor = UIColor(red: 0.623, green: 0.65, blue: 0.692, alpha: 0.2).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 40
        layer.shadowOffset = CGSize(width: 0, height: 8)
        
        updateShadowFrame()
    }
    
    func updateShadowFrame() {
        layer.shadowPath = UIBezierPath(roundedRect: backgroundView.frame, cornerRadius: 16).cgPath
    }
    
    @IBAction func subscribe(_ sender: Any) {
        subscription()
    }
}
