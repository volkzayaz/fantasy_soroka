//
//  RoomsViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RoomsViewController: UIViewController, MVVM_View {

    lazy var viewModel: RoomsViewModel! = .init(router: .init(owner: self))

    @IBOutlet private var tableView: UITableView! {
        didSet {
            
            let control = UIRefreshControl()
            control.addTarget(self, action: "pullToRefresh", for: .valueChanged)
            
            tableView.refreshControl = control
        }
    }
    @IBOutlet private var createRoomButton: SecondaryButton!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RoomsViewModel.RoomCell>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.roomTableViewCell,
                                                 for: indexPath)!
            
        cell.set(model: model)
            
        return cell
    }, titleForHeaderInSection: { dataSource, index in
        return dataSource.sectionModels[index].model
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyGradient()
        
        configure()
    }
}

extension RoomsViewController {
    @IBAction func addNewRoom() {
        viewModel.createRoom()
    }

    func configure() {
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(RoomsViewModel.RoomCell.self)
            .subscribe(onNext: { [unowned self] cellModel in
                self.viewModel.roomTapped(roomCell: cellModel)
        }).disposed(by: rx.disposeBag)

        createRoomButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
    }
    
    @objc func pullToRefresh() {
        viewModel.refreshRooms()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
}
