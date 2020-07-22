//
//  DeckLimitedOfferController.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 20.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DeckLimitedOfferController: UITableViewController, MVVM_View {
    
    @IBOutlet weak var subscribeButton: SecondaryButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var cardView: CollectionCardView!
    
    var viewModel: DeckLimitedOfferViewModel!
    var plan: DeckOffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.offerType == .promo ? R.string.localizable.subscriptionLimitedOfferNavigationTitle() :
            R.string.localizable.subscriptionOnetimeOfferNavigationTitle()

        roundedView.clipsToBounds = true
        roundedView.layer.cornerRadius = 20
        priceView.clipsToBounds = true
        priceView.layer.cornerRadius = 20
        
        cardView.model = viewModel.collection
        cardView.set(imageURL: viewModel.collection.imageURL)
        cardView.title = viewModel.collection.title
        cardView.isPurchased = viewModel.collection.isPurchased
        
        saveView.backgroundColor = .clear;
        saveView.addFantasySubscriptionGradient(radius: true)
        
        roundedView.addFantasyRoundedCorners()
        navigationController?.view.addFantasySubscriptionGradient()
        edgesForExtendedLayout = []
        
        viewModel.offer.drive(onNext: { [unowned self] x in
            guard let plan = x else { return }
            
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


final class CollectionCardView: UIView {
    
    @IBOutlet var imageView: ProtectedImageView!
    @IBOutlet var paidView: UIView!
    @IBOutlet var paidLabel: UILabel!
    @IBOutlet var paidImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fantasiesCountLabel: UILabel!
    @IBOutlet weak var myDeckIndicator: UIView!
    private var gradientLayer = CAGradientLayer()

    var model: Fantasy.Collection! {
        didSet {
            fantasiesCountLabel.text = "\(model.cardsCount) \(model.itemsNamePlural)"
            paidLabel.text = model.category
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var fantasiesCount: Int = 0 {
        didSet {
            fantasiesCountLabel.text = R.string.localizable.fantasyCollectionCardsCount(fantasiesCount)
        }
    }

    var isPurchased: Bool = false {
        didSet {
            myDeckIndicator.isHidden = !isPurchased
        }
    }

    func set(imageURL: String) {
        imageView.set(imageURL: imageURL, isProtected: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyling()
        
        title = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        paidView.layer.cornerRadius = paidView.frame.height / 2.0
        gradientLayer.frame = bounds
    }

    private func configureStyling() {
        layer.cornerRadius = 16.0
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.layer.addSublayer(gradientLayer)

        paidImageView.image = R.image.paidCollection()

        paidView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        paidView.clipsToBounds = true

        paidLabel.text = R.string.localizable.fantasyCollectionPaidIndicator()
        paidLabel.textColor = .title
        paidLabel.font = .mediumFont(ofSize: 12)

        titleLabel.textColor = .title
        titleLabel.font = .boldFont(ofSize: 15)

        fantasiesCountLabel.textColor = .title
        fantasiesCountLabel.font = .regularFont(ofSize: 15)

        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0.7]
    }
}
