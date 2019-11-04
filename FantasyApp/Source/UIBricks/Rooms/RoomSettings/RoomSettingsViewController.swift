//
//  RoomSettingsViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Kingfisher

class RoomSettingsViewController: UIViewController, MVVM_View {
    var viewModel: RoomSettingsViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
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
    @IBOutlet private var leaveRoomButton: UIButton!

    lazy var participantsDataSource = RxCollectionViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, RoomSettingsViewModel.CellModel>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

        switch model {
            
        case .user(let isAdmin, let participant):
            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.participantCollectionViewCell,
                                     for: indexPath)!
            
            cell.nameLabel.text = participant.userSlice.name
            cell.adminLabel.isHidden = !isAdmin
            cell.status = isAdmin ? nil : participant.status
            
            ImageRetreiver.imageForURLWithoutProgress(url: participant.userSlice.avatarURL)
                .map { $0 ?? R.image.errorPhoto() }
                .drive(cell.imageView.rx.image)
                .disposed(by: self.rx.disposeBag)
            return cell
            
        case .invite:
            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.inviteParticipantCollectionViewCell,
                                     for: indexPath)!
            
            cell.setMode(isWaiting: false)
            
            return cell
            
        case .waiting:
            
            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.inviteParticipantCollectionViewCell,
                                     for: indexPath)!
            
            cell.setMode(isWaiting: true)
            
            return cell
            
        }
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        self.inviteLabel?.removeFromSuperview()
        self.inviteView?.removeFromSuperview()
        
        viewModel.intiteLinkShow
            .drive(onNext: { [unowned self] (_) in
                self.stackView.insertArrangedSubview(self.inviteLabel, at: 1)
                self.stackView.insertArrangedSubview(self.inviteView, at: 2)
                
                self.stackView.setCustomSpacing(22, after: self.inviteView)
            })
            .disposed(by: rx.disposeBag)
        
        participantsCollectionView.rx.modelSelected(RoomSettingsViewModel.CellModel.self)
            .subscribe(onNext: { [unowned self] (x) in
                
                if case .user(_, let participant) = x {
                    self.viewModel.showParticipant(participant: participant)
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.roundCorners([.topLeft, .topRight], radius: 20)
        
        
    }
}

private extension RoomSettingsViewController {
    func configure() {
        stackView.setCustomSpacing(16, after: titleLabel)
        stackView.setCustomSpacing(10, after: inviteLabel)
        stackView.setCustomSpacing(16, after: participantsLabel)
        stackView.setCustomSpacing(12, after: participantsCollectionView)
        stackView.setCustomSpacing(12, after: notificationsView)
        stackView.setCustomSpacing(26, after: securitySettingsView)

        scrollView.backgroundColor = .messageBackground
        stackView.backgroundColor = .messageBackground
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

        leaveRoomButton.setTitle(R.string.localizable.roomSettingsLeaveRoom(), for: .normal)
        leaveRoomButton.setTitleColor(.fantasyRed, for: .normal)
        leaveRoomButton.titleLabel?.font = .mediumFont(ofSize: 15)
        leaveRoomButton.backgroundColor = .white

        leaveRoomButton.layer.cornerRadius = 12.0
        inviteView.layer.cornerRadius = 12.0
        notificationsView.layer.cornerRadius = 12.0

        securitySettingsView.didChangeOptions = { [weak self] options in
            self?.viewModel.setIsScreenShieldEnabled(options.first?.1 ?? false)
        }

        viewModel.participantsDataSource
            .drive(participantsCollectionView.rx.items(dataSource: participantsDataSource))
            .disposed(by: rx.disposeBag)

        viewModel.room.asDriver().drive(onNext: { [weak self] room in
            self?.securitySettingsView.viewModel = self?.viewModel.securitySettingsViewModelFor(room: room)
        }).disposed(by: rx.disposeBag)

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

    @IBAction func editNotificationSettings() {
        viewModel.showNotificationSettings()
    }

    @IBAction func leaveRoom() {
        viewModel.leaveRoom()
    }
}
