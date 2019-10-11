//
//  RoomCreationViewController.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomCreationViewController: UIViewController, MVVM_View {
    var viewModel: RoomCreationViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var inviteView: UIView!
    @IBOutlet private var inviteLabel: UILabel!
    @IBOutlet private var inviteLinkLabel: UILabel!
    @IBOutlet private var copyLinkButton: SecondaryButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension RoomCreationViewController {
    func configure() {
        contentView.backgroundColor = .messageBackground
        inviteView.backgroundColor = .white
        
        titleLabel.font = .boldFont(ofSize: 25)
        titleLabel.textColor = .fantasyBlack
        titleLabel.text = R.string.localizable.roomCreationTitle()

        inviteLabel.font = .boldFont(ofSize: 15)
        inviteLabel.textColor = .fantasyBlack
        inviteLabel.text = R.string.localizable.roomCreationInvite()

        inviteLinkLabel.font = .regularFont(ofSize: 15)
        inviteLinkLabel.textColor = .basicGrey
        viewModel.inviteLink.asDriver().drive(onNext: { [weak self] link in
            self?.inviteLinkLabel.text = link
        }).disposed(by: rx.disposeBag)

        copyLinkButton.setTitle(R.string.localizable.roomCreationInviteCopy(), for: .normal)

        inviteView.layer.cornerRadius = 12.0
    }

    @IBAction func copyLink() {
        UIPasteboard.general.string = viewModel.inviteLink.value
    }
}
