//
//  RoomsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.09.2019.
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
            tableView.backgroundColor = R.color.bgLightGrey()
        }
    }
    @IBOutlet private var createRoomButton: SecondaryButton!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RoomsViewModel.RoomCell>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.roomTableViewCell,
                                                 for: indexPath)!
            
        cell.set(model: model)
            
        return cell
    }
//        , titleForHeaderInSection: { dataSource, index in
//        return dataSource.sectionModels[index].model
//    }
    )

    lazy var emptyView: EmptyView! = tableView.addEmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyGradient()
        navigationItem.title = "Rooms"
 
        emptyView.emptyView = UIImageView(image: R.image.room_placeholder())
        
         viewModel.dataSource
            .map { $0.count == 0 }
            .drive(emptyView.rx.isEmpty)
            .disposed(by: rx.disposeBag)
        
        viewModel.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(RoomsViewModel.RoomCell.self)
            .subscribe(onNext: { [unowned self] cellModel in
                self.viewModel.roomTapped(roomCell: cellModel)
        }).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        createRoomButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
    }
}

//MARK:- Actions

extension RoomsViewController {
    @IBAction func addNewRoom() {
        viewModel.createRoom()
    }

    @objc func pullToRefresh() {
        viewModel.refreshRooms()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
}

//MARK:- UITableViewDelegate

extension RoomsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
}
