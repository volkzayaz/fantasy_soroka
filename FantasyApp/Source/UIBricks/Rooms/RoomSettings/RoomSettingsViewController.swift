//
//  RoomSettingsViewController.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Kingfisher

class RoomSettingsViewController: UIViewController, MVVM_View {
    var viewModel: RoomSettingsViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var inviteView: UIView!
    @IBOutlet private var inviteLabel: UILabel!
    @IBOutlet private var notificationsView: UIView!
    @IBOutlet private var notificationsLabel: UILabel!
    @IBOutlet private var participantsCollectionView: UICollectionView!
    @IBOutlet private var securitySettingsView: RoomSettingsPremiumFeatureView!
    @IBOutlet private var inviteLinkLabel: UILabel!
    @IBOutlet private var participantsLabel: UILabel!
    @IBOutlet private var copyLinkButton: SecondaryButton!
    @IBOutlet private var seeParticipantsButton: UIButton!
    @IBOutlet private var leaveRoomButton: UIButton!

    lazy var participantsDataSource = RxCollectionViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, RoomSettingsViewModel.CellModel>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

        switch model {
        case .user(let thumbnailURL, let isAdmin, let name, let status, _):
            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.participantCollectionViewCell,
                                     for: indexPath)!
            cell.nameLabel.text = name
            cell.adminLabel.isHidden = !isAdmin
            cell.status = isAdmin ? nil : status
            ImageRetreiver.imageForURLWithoutProgress(url: thumbnailURL)
                .map { $0 ?? R.image.errorPhoto() }
                .drive(cell.imageView.rx.image)
                .disposed(by: self.rx.disposeBag)
            return cell
            
        case .invite:
            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.inviteParticipantCollectionViewCell,
                                     for: indexPath)!
            return cell
        }
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension RoomSettingsViewController {
    func configure() {
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .messageBackground
        contentView.backgroundColor = .messageBackground
        inviteView.backgroundColor = .white
        
        titleLabel.font = .boldFont(ofSize: 25)
        titleLabel.textColor = .fantasyBlack
        titleLabel.text = R.string.localizable.roomCreationTitle()

        inviteLabel.font = .boldFont(ofSize: 15)
        inviteLabel.textColor = .fantasyBlack
        inviteLabel.text = R.string.localizable.roomCreationInvite()

        notificationsLabel.font = .boldFont(ofSize: 15)
        notificationsLabel.textColor = .fantasyBlack
        notificationsLabel.text = R.string.localizable.roomCreationNotifications()

        participantsLabel.font = .boldFont(ofSize: 15)
        participantsLabel.textColor = .fantasyBlack
        participantsLabel.text = R.string.localizable.roomCreationParticipants()

        inviteLinkLabel.font = .regularFont(ofSize: 15)
        inviteLinkLabel.textColor = .basicGrey
        viewModel.inviteLink.asDriver().drive(onNext: { [weak self] link in
            self?.inviteLinkLabel.text = link
        }).disposed(by: rx.disposeBag)

        copyLinkButton.setTitle(R.string.localizable.roomCreationInviteCopy(), for: .normal)

        seeParticipantsButton.setTitle(R.string.localizable.roomCreationParticipantsSeeAll(), for: .normal)
        seeParticipantsButton.backgroundColor = .fantasyGrey
        seeParticipantsButton.setTitleColor(.fantasyPink, for: .normal)
        seeParticipantsButton.titleLabel?.font = .boldFont(ofSize: 14)
        seeParticipantsButton.layer.cornerRadius = seeParticipantsButton.bounds.height / 2.0

        leaveRoomButton.setTitle(R.string.localizable.roomSettingsLeaveRoom(), for: .normal)
        leaveRoomButton.setTitleColor(.fantasyRed, for: .normal)
        leaveRoomButton.titleLabel?.font = .mediumFont(ofSize: 15)
        leaveRoomButton.backgroundColor = .white

        leaveRoomButton.layer.cornerRadius = 12.0
        inviteView.layer.cornerRadius = 12.0
        notificationsView.layer.cornerRadius = 12.0

        securitySettingsView.viewModel = viewModel.securitySettingsViewModel
        securitySettingsView.didChangeOptions = { [weak self] options in
            self?.viewModel.setIsScreenShieldEnabled(options.first?.1 ?? false)
        }

        viewModel.participantsDataSource
            .drive(participantsCollectionView.rx.items(dataSource: participantsDataSource))
            .disposed(by: rx.disposeBag)

        participantsCollectionView.rx.modelSelected(RoomSettingsViewModel.CellModel.self)
            .subscribe(onNext: { [unowned self] cellModel in
                switch cellModel {
                case .invite:
                    self.viewModel.shareLink()
                default:
                    break
                }
        }).disposed(by: rx.disposeBag)
    }

    @IBAction func copyLink() {
        UIPasteboard.general.string = viewModel.inviteLink.value
    }

    @IBAction func seeAllParticipants() {

    }

    @IBAction func editNotificationSettings() {

    }

    @IBAction func leaveRoom() {

    }
}
