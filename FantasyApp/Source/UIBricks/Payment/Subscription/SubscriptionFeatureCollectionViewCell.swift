//
//  SubscriptionFeatureCollectionViewCell.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 02.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

extension SubscriptionFeatureCollectionViewCell {
    
    func setUp(page: SubscriptionViewModel.Page) {
        switch page {
        case .accessToAllDecks:
            imageView.image = R.image.memberAccessToDecksNew()
            titleLabel.text = R.string.localizable.getMembershipAccessToAllDecksTitle()
            descriptionLabel.text = R.string.localizable.getMembershipAccessToAllDecksSubtitle()
        case .x3NewProfilesDaily:
            imageView.image = R.image.memberProfilesNew()
            titleLabel.text = R.string.localizable.getMembershipX3NewProfilesTitle()
            descriptionLabel.text = R.string.localizable.getMembershipX3NewProfilesSubtitle()
        case .globalMode:
            imageView.image = R.image.memberGlobalNew()
            titleLabel.text = R.string.localizable.getMembershipGlobalModeTitle()
            descriptionLabel.text = R.string.localizable.getMembershipGlobalModeSubtitle()
        case .changeActiveCity:
            imageView.image = R.image.memberActiveCityNew()
            titleLabel.text = R.string.localizable.getMembershipChangeActiveCityTitle()
            descriptionLabel.text = R.string.localizable.getMembershipChangeActiveCitySubtitle()
        case .x3NewCardsDaily:
            imageView.image = R.image.memberCardsNew()
            titleLabel.text = R.string.localizable.getMembershipX3NewFantasiesTitle()
            descriptionLabel.text = R.string.localizable.getMembershipX3NewFantasiesSubtitle()
        case .unlimitedRooms:
            imageView.image = R.image.memberRoomsNew()
            titleLabel.text = R.string.localizable.getMembershipUnlimitedRoomsTitle()
            descriptionLabel.text = R.string.localizable.getMembershipUnlimitedRoomsSubtitle()
        case .memberBadge:
            imageView.image = R.image.memberBadgeNew()
            titleLabel.text = R.string.localizable.getMembershipMemberBadgeTitle()
            descriptionLabel.text = R.string.localizable.getMembershipMemberBadgeSubtitle()
        }
    }
}

class SubscriptionFeatureCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
}
