//
//  RoomsViewController.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RoomsViewController: UIViewController, MVVM_View {

    lazy var viewModel: RoomsViewModel! = .init(router: .init(owner: self))

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var createRoomButton: SecondaryButton!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RoomsViewModel.CellModel>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.roomTableViewCell,
                                                 for: indexPath)!
        cell.nameLabel.text = model.companionName
        cell.timeLabel.text = model.updatedAt
        cell.lastMessageLabel.text = model.lastMessage

        return cell
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(Chat.Room.self)
            .subscribe(onNext: { [unowned self] room in
            self.viewModel.roomTapped(room)
        }).disposed(by: rx.disposeBag)

        //viewModel.fetchRooms()
    }

}

private extension RoomsViewController {
    @IBAction private func addNewRoom() {

    }

    func configure() {
        createRoomButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
    }
}
