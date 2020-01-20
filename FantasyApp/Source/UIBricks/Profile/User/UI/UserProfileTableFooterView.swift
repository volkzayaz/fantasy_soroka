//
//  UserProfileTableFooterView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 11.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift

class UserProfileTableFooterView: UIView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!

    var disposeBag = DisposeBag()

    var viewModel: UserProfileViewModel? {
        didSet {

            guard let vm = viewModel else { return }

            vm.registeredDateText.drive(dateLabel.rx.text)
                .disposed(by: disposeBag)

            vm.userIdText.drive(userIDLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }
}
