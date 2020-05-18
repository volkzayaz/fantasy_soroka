//
//  ConnectionViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class ConnectionViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: ConnectionViewModel! = ConnectionViewModel(router: .init(owner: self))
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ConnectedUser>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        if x.source == .outgoing {
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.outgoingConnectionCell,
                                              for: ip)!
            
            cell.set(connection: x)
            
            return cell
            
        }
        else {

            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.incommingConnectionCell,
                                              for: ip)!
            
            cell.set(connection: x)
            
            return cell
            
        }
        
    })
    @IBOutlet weak var gradientView: UIView!
    lazy var emptyView: EmptyView! = collectionView.addEmptyView()
    
    @IBOutlet weak var incommingButton: PrimaryButton! {
        didSet {
            incommingButton.mode = .selector
            incommingButton.useTransparency = false
            incommingButton.setTitleColor(UIColor.fantasyPink, for: .selected)
            incommingButton.setTitleColor(UIColor.white, for: .normal)
            incommingButton.setTitle(R.string.localizable.connectionIncomingButton(), for: .normal)
        }
    }
    @IBOutlet weak var outgoingButton: PrimaryButton! {
        didSet {
            outgoingButton.mode = .selector
            outgoingButton.useTransparency = false
            outgoingButton.setTitleColor(UIColor.fantasyPink, for: .selected)
            outgoingButton.setTitleColor(UIColor.white, for: .normal)
            outgoingButton.setTitle(R.string.localizable.connectionOutgoingButton(), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = R.string.localizable.connectionTitle()
        
        viewModel.requests
            .do(onNext: { [unowned self] (sections) in

                let layout = (self.collectionView.collectionViewLayout as! BaseFlowLayout)
                let mode = sections.first?.items.first?.source ?? .outgoing
                
                self.collectionView.performBatchUpdates({
                    layout.tableMode = mode
                    (self.collectionView.collectionViewLayout as! BaseFlowLayout).configureFor(bounds: self.view.bounds)
                }, completion: nil)
                
            })
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        viewModel.requests
            .map { $0.first!.items.count == 0 }
            .drive(emptyView.rx.isEmpty)
            .disposed(by: rx.disposeBag)
        
        viewModel.sourceDriver
            .drive(onNext: { [unowned self] source in
                self.emptyView.subviews.forEach { $0.removeFromSuperview() }
                
                let view = source == .incomming ? EmptyIncomingView() : EmptyOutgoingView()
                self.emptyView.addSubview(view)
                view.snp.makeConstraints { $0.edges.equalToSuperview() }
            })
            .disposed(by: rx.disposeBag)
        

        collectionView.rx.modelSelected(ConnectedUser.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.show(room: x.room)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewAppeared()
        gradientView.addFantasyGradient()
    }
    
}

extension ConnectionViewController {

    @IBAction func incommingAction(_ sender: Any) {
        incommingButton.isSelected = true
        outgoingButton.isSelected = false
        
        viewModel.sourceChanged(source: .incomming )
    }
    
    @IBAction func outgoingAction(_ sender: Any) {
        incommingButton.isSelected = false
        outgoingButton.isSelected = true
        
        viewModel.sourceChanged(source: .outgoing )
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension ConnectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (collectionView.collectionViewLayout as! BaseFlowLayout).itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return (collectionView.collectionViewLayout as! BaseFlowLayout).sectionInset
    }

}

class BaseFlowLayout: UICollectionViewFlowLayout {
    
    var tableMode: GetConnectionRequests.Source = .incomming
    
    func configureFor(bounds: CGRect) {
        
        if tableMode == .outgoing {

            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            sectionInset = .init(top: 0, left: 0, bottom: 40, right: 0)
            itemSize = CGSize(width: bounds.size.width, height: 77)
            
            return;
        }
        
        itemSize = .init(width: 300, height: 300)
        
        minimumInteritemSpacing = 17
        minimumLineSpacing = 17
        
        sectionInset = .init(top: 17, left: 17, bottom: 17, right: 17)

        let offset = minimumInteritemSpacing + sectionInset.left + sectionInset.right
        let viewWidth = bounds.width
        let lineWidth = offset + 2 * itemSize.width
        
        if lineWidth > viewWidth {
            let itemWidth = (viewWidth - offset) / 2
            itemSize = CGSize(width: floor(itemWidth),
                              height: itemWidth * 1.487)
        }
        
    }

}

final class EmptyIncomingView: UIView {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.emptyIncoming()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = R.string.localizable.notificationsEmptyIncomingTitle()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = R.string.localizable.notificationsEmptyIncomingSubtitle()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        label.numberOfLines = 0
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
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(70)
            $0.centerY.equalToSuperview().multipliedBy(0.8)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(16)
            $0.left.equalTo(55)
            $0.right.equalTo(-55)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalTo(titleLabel)
        }
    }
}


final class EmptyOutgoingView: UIView {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.emptyOutgoing()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = R.string.localizable.notificationsEmptyOutgoingTitle()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = R.string.localizable.notificationsEmptyOutgoingSubtitle()
        label.textColor = R.color.textBlackColor()
        label.textAlignment = .center
        label.numberOfLines = 0
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
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(70)
            $0.centerY.equalToSuperview().multipliedBy(0.8)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(16)
            $0.left.equalTo(55)
            $0.right.equalTo(-55)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalTo(titleLabel)
        }
    }
}
