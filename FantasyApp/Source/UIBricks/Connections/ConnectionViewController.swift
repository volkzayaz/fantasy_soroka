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
        }
    }
    @IBOutlet weak var outgoingButton: PrimaryButton! {
        didSet {
            outgoingButton.mode = .selector
            outgoingButton.useTransparency = false
            outgoingButton.setTitleColor(UIColor.fantasyPink, for: .selected)
            outgoingButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        viewModel.sourceDriver.map { source in
            let image = source == .incomming ? R.image.incommingConnectionsPlaceholder() : R.image.outgoingConnectionsPlaceholder()
            
            return UIImageView(image: image)
        }
        .drive(emptyView.rx.emptyView)
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
