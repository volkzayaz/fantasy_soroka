//
//  RoomCreationViewController.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Kingfisher

class RoomCreationViewController: UIViewController, MVVM_View {
    var viewModel: RoomCreationViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var inviteView: UIView!
    @IBOutlet private var inviteLabel: UILabel!
    @IBOutlet private var participantsCollectionView: UICollectionView!
    @IBOutlet private var inviteLinkLabel: UILabel!
    @IBOutlet private var participantsLabel: UILabel!
    @IBOutlet private var copyLinkButton: SecondaryButton!
    @IBOutlet private var seeParticipantsButton: UIButton!

    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, RoomCreationViewModel.CellModel>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

            let cell = self.participantsCollectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.participantCollectionViewCell,
                                     for: indexPath)!
            cell.nameLabel.text = model.name
            cell.adminLabel.isHidden = !model.isAdmin
            ImageRetreiver.imageForURLWithoutProgress(url: model.thumbnailURL)
                .map { $0 ?? R.image.errorPhoto() }
                .drive(cell.imageView.rx.image)
                .disposed(by: self.rx.disposeBag)

        return cell
    })

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
        seeParticipantsButton.backgroundColor = .seeParticipantsButton
        seeParticipantsButton.setTitleColor(.fantasyPink, for: .normal)
        seeParticipantsButton.titleLabel?.font = .boldFont(ofSize: 14)
        seeParticipantsButton.layer.cornerRadius = seeParticipantsButton.bounds.height / 2.0

        inviteView.layer.cornerRadius = 12.0

        viewModel.dataSource
            .drive(participantsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

//        participantsCollectionView.rx.modelSelected(RoomsViewModel.CellModel.self)
//            .subscribe(onNext: { [unowned self] cellModel in
//            //
//        }).disposed(by: rx.disposeBag)

    }

    @IBAction func copyLink() {
        UIPasteboard.general.string = viewModel.inviteLink.value
    }

    @IBAction func seeAllParticipants() {

    }
}
