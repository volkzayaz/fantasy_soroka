//
//  RoomSettingsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import Kingfisher

class RoomSettingsViewController: UIViewController, MVVM_View {
    var viewModel: RoomSettingsViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var inviteView: UIView!
    @IBOutlet private var inviteLabel: UILabel!
    @IBOutlet private var decksLabel: UILabel!
    @IBOutlet private var notificationsView: UIView!
    @IBOutlet private var notificationsLabel: UILabel!
    @IBOutlet private var participantsCollectionView: UICollectionView!
    @IBOutlet private var deckCollectionView: UICollectionView! {
        didSet {
            let cellSize = CGSize(width: 170, height:250)

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = cellSize
            layout.minimumLineSpacing = 8.0
            layout.minimumInteritemSpacing = 1.0
            deckCollectionView.setCollectionViewLayout(layout, animated: true)
        }
    }
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
    
    lazy var deckDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Fantasy.Request.LikedCards.SneakPeek>>(configureCell: { [unowned self] (_, cv, ip, model) in
        
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                              for: ip)!
            
            let i = [R.image.collectionStubBlured()!,
                R.image.gay()!,
                R.image.transsexual()!,
                R.image.pansexual()!
            ].randomElement()!
            
            cell.imageView.regularImageView.image = i
            cell.isPurchased = false //sneakPeek.isPaid
            
            cell.fantasiesCountLabel.text = "\(model.amountlikedCardsByUser) \(model.coverItems)"
            cell.paidLabel.text = model.coverRubric
            
            return cell
        
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        securitySettingsView.viewModel = viewModel

        viewModel.intiteLinkHidden
            .drive(inviteView.rx.hidden(in: stackView))
            .disposed(by: rx.disposeBag)
        
        viewModel.inviteLink.asDriver()
            .drive(inviteLinkLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.title.asDriver()
            .drive(titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.destructiveButtonTitle
            .drive(leaveRoomButton.rx.title(for: .normal))
            .disposed(by: rx.disposeBag)
        
        viewModel.destructiveButtonTitle
            .map { $0 == nil }
            .drive(leaveRoomButton.rx.hidden(in: stackView))
            .disposed(by: rx.disposeBag)
        
        participantsCollectionView.rx.modelSelected(RoomSettingsViewModel.CellModel.self)
            .subscribe(onNext: { [unowned self] (x) in
                
                switch x {
                case .user(_, let participant):
                    self.viewModel.showParticipant(participant: participant)
                    
                case .invite:
                    self.viewModel.shareLink(type: .add)
                    
                case .waiting:
                    break;
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.participantsDataSource
            .drive(participantsCollectionView.rx.items(dataSource: participantsDataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.deckDataSource
            .map { [SectionModel(model: "", items: $0)] }
            .drive(deckCollectionView.rx.items(dataSource: deckDataSource))
            .disposed(by: rx.disposeBag)
            
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.generalDone(),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(RoomSettingsViewController.close))
        
        if SettingsStore.showRoomTutorial.value {
            let vc = R.storyboard.rooms.roomTutorial()!
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
            SettingsStore.showRoomTutorial.value = false
        }
        
        NotificationCenter.default.rx.notification(Notification.Name("screenCancel"))
            .subscribe(onNext: { [weak self] (_) in
                self?.securitySettingsView.switches.first?.isOn = false
            })
        
        securitySettingsView.removeFromSuperview()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

private extension RoomSettingsViewController {
    func configure() {
        view.addFantasyGradient()
        
        deckCollectionView.register(R.nib.fantasyCollectionCollectionViewCell)
        
        stackView.setCustomSpacing(16, after: titleLabel)
        stackView.setCustomSpacing(10, after: inviteLabel)
        stackView.setCustomSpacing(22, after: inviteView)
        stackView.setCustomSpacing(16, after: participantsLabel)
        stackView.setCustomSpacing(12, after: participantsCollectionView)
        stackView.setCustomSpacing(12, after: notificationsView)
        stackView.setCustomSpacing(26, after: securitySettingsView)
        
        scrollView.backgroundColor = .messageBackground
        scrollView.addFantasyRoundedCorners()
        inviteView.backgroundColor = .white
        
        titleLabel.font = .boldFont(ofSize: 25)
        titleLabel.textColor = .fantasyBlack
        
        inviteLabel.font = .boldFont(ofSize: 15)
        inviteLabel.textColor = .fantasyBlack
        
        inviteLabel.text = R.string.localizable.roomCreationInvite()

        notificationsLabel.font = .boldFont(ofSize: 15)
        notificationsLabel.textColor = .fantasyBlack
        notificationsLabel.text = R.string.localizable.roomCreationNotifications()

        participantsLabel.font = .boldFont(ofSize: 15)
        participantsLabel.textColor = .fantasyBlack
        participantsLabel.text = R.string.localizable.roomCreationParticipants()
        
        decksLabel.font = .boldFont(ofSize: 15)
        decksLabel.textColor = .fantasyBlack
        
        deckCollectionView.backgroundColor = .clear
        
        inviteLinkLabel.font = .regularFont(ofSize: 15)
        inviteLinkLabel.textColor = .basicGrey
        
        leaveRoomButton.setTitleColor(.fantasyRed, for: .normal)
        leaveRoomButton.titleLabel?.font = .mediumFont(ofSize: 15)
        leaveRoomButton.backgroundColor = .white

        leaveRoomButton.layer.cornerRadius = 12.0
        inviteView.layer.cornerRadius = 12.0
        notificationsView.layer.cornerRadius = 12.0

    }

    @IBAction func copyLink() {
        self.viewModel.shareLink(type: .share)
    }

    @IBAction func editNotificationSettings() {
        viewModel.showNotificationSettings()
    }

    @IBAction func leaveRoom() {
        viewModel.leaveRoom()
    }
}
