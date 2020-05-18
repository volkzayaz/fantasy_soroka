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
        }
    }
    @IBOutlet private var createRoomButton: SecondaryButton!

    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Room>>(
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
        navigationItem.title = R.string.localizable.roomListTitle()
         
        let emptyRoomsView = EmptyRoomsView()
        self.emptyView.addSubview(emptyRoomsView)
        emptyRoomsView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyView.emptyView?.alpha = 1

        viewModel.indicator.asDriver()
            .drive(onNext: { [weak self] (loading) in
                
                if loading {
                    self?.tableView.refreshControl?.beginRefreshing()
                    let offsetPoint = CGPoint.init(x: 0, y: -(self?.tableView.refreshControl?.frame.size.height ?? 0))
                    self?.tableView.setContentOffset(offsetPoint, animated: true)
                }
                else {
                    self?.tableView.refreshControl?.endRefreshing()
                }
                
            })
            .disposed(by: rx.disposeBag)
        
         viewModel.dataSource
            .map { $0.count != 0 }
            .drive(emptyView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.dataSource
            .map { $0.count == 0 ? UIColor.white : R.color.bgLightGrey()! }
            .drive(onNext: { [weak self] (x) in
                self?.tableView.backgroundColor = x
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.dataSource
            .do(onNext: { [weak self] (_) in
                self?.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(Room.self)
            .subscribe(onNext: { [unowned self] cellModel in
                self.viewModel.roomTapped(room: cellModel)
        }).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        createRoomButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.roomListAdd(), style: .done, target: self, action: #selector(self.addNewRoom))
    }
}

//MARK:- Actions

extension RoomsViewController {
    @IBAction func addNewRoom() {
        viewModel.createRoom()
    }

    @objc func pullToRefresh() {
        viewModel.refreshRooms()
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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


final class EmptyRoomsView: UIView {
    
    private let firstStepView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.room_empty_first()
        return imageView
    }()
    
    private let firstStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = R.string.localizable.createRoomFirstStep()
        label.textColor = R.color.textPinkColor()
        return label
    }()
    
    private let secondStepView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.room_empty_second()
        return imageView
    }()
    
    private let secondStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = R.string.localizable.createRoomSecondStep()
        label.textColor = R.color.textPinkColor()
        return label
    }()
    
    private let thirdStepView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.room_empty_third()
        return imageView
    }()
    
    private let thirdStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = R.string.localizable.createRoomThirdStep()
        label.textColor = R.color.textPinkColor()
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = R.string.localizable.createRoomTitle()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = R.string.localizable.createRoomDescription()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    private func layout() {
        addSubview(firstStepView)
        firstStepView.snp.makeConstraints {
            $0.height.equalTo(67)
            $0.width.equalTo(220)
            $0.centerY.equalToSuperview().multipliedBy(0.6)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(firstStepLabel)
        firstStepLabel.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.bottom.equalTo(firstStepView).offset(-9)
            $0.left.equalTo(firstStepView).offset(52)
            $0.right.equalTo(firstStepView)
        }
        
        addSubview(secondStepView)
        secondStepView.snp.makeConstraints {
            $0.width.equalTo(firstStepView)
            $0.centerX.equalTo(firstStepView)
            $0.height.equalTo(52)
            $0.top.equalTo(firstStepView.snp.bottom).offset(8)
        }
        
        addSubview(secondStepLabel)
        secondStepLabel.snp.makeConstraints {
            $0.height.equalTo(firstStepLabel)
            $0.bottom.equalTo(secondStepView).offset(-9)
            $0.left.equalTo(firstStepLabel)
            $0.right.equalTo(firstStepLabel)
        }
        
        addSubview(thirdStepView)
        thirdStepView.snp.makeConstraints {
            $0.width.equalTo(firstStepView)
            $0.centerX.equalTo(firstStepView)
            $0.height.equalTo(86)
            $0.top.equalTo(secondStepView.snp.bottom).offset(8)
        }
        
        addSubview(thirdStepLabel)
        thirdStepLabel.snp.makeConstraints {
            $0.height.equalTo(firstStepLabel)
            $0.top.equalTo(thirdStepView).offset(9)
            $0.left.equalTo(firstStepLabel)
            $0.right.equalTo(firstStepLabel)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(thirdStepView.snp.bottom).offset(75)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
