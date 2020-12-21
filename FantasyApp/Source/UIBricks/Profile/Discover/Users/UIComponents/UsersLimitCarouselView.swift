//
//  UsersLimitCarouselView.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 19.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol UsersLimitCarouselViewDelegate: class {
    func usersLimitCarouselViewGetMembership(_ view: UsersLimitCarouselView)
}

class UsersLimitCarouselView: UIView {
    
    weak var delegate: UsersLimitCarouselViewDelegate?
    
    init(frame: CGRect, limitExpirationDate: Driver<Date?>, isGetMembershipHidden: Driver<Bool>) {
        super.init(frame: frame)
        
        loadFromNib()
        setUpAppearance()
        
        limitExpirationDate
            .notNil()
            .flatMapLatest { date in
                Driver<Int>.interval(.seconds(1)).startWith(0).map { _ in
                    let string = date.toTimeLeftString()
                    let attributedString = NSMutableAttributedString(string: string)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.fantasyPink, range: (string as NSString).range(of: string))
                    return attributedString
                }
            }.drive(timeLeftLabel.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        isGetMembershipHidden
            .drive(getMembershipView.rx.isHidden)
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var dailyLimitReachedLabel: UILabel!
    @IBOutlet private weak var discoverNewProfilesLabel: UILabel!
    @IBOutlet private weak var timeLeftLabel: UILabel!
    @IBOutlet private weak var doNotWaitLabel: UILabel!
    @IBOutlet private weak var getMembershipView: UIView!
    @IBOutlet private weak var getMembershipButton: UIButton!
}

private extension UsersLimitCarouselView {
    
    func setUpAppearance() {
        clipsToBounds = true
        layer.cornerRadius = 20
        
        dailyLimitReachedLabel.text = R.string.localizable.profileDiscoverUsersDailyLimitDescription()
        discoverNewProfilesLabel.text = R.string.localizable.profileDiscoverUsersDailyLimitDiscoverNewProfiles()
        doNotWaitLabel.text = R.string.localizable.profileDiscoverUsersDailyLimitSubscriptionLabel()
        getMembershipButton.setTitle(R.string.localizable.getMembershipGetButton(), for: .normal)
        
        getMembershipView.isHidden = (getMembership == nil)
    }
    
    @IBAction func getMembership(_ sender: Any) {
        delegate?.usersLimitCarouselViewGetMembership(self)
    }
}
