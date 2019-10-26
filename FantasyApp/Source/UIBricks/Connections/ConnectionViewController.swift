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
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.incommingConnectionCell,
                                          for: ip)!
        
        cell.set(connection: x)
        
        return cell
        
    })
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var incommingButton: PrimaryButton! {
        didSet {
            incommingButton.mode = .selector
            incommingButton.titleFont = .mediumFont(ofSize: 15)
        }
    }
    @IBOutlet weak var outgoingButton: PrimaryButton! {
        didSet {
            outgoingButton.mode = .selector
            incommingButton.titleFont = .mediumFont(ofSize: 15)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (collectionView.collectionViewLayout as! BaseFlowLayout).configureFor(bounds: view.bounds)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: "dos")
        
        viewModel.requests
            .drive(collectionView.rx.items(dataSource: dataSource))
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

    @objc func dos() {
        let layout = collectionView.collectionViewLayout as! BaseFlowLayout
        
        self.collectionView.performBatchUpdates({
            layout.tableMode = !layout.tableMode
            (self.collectionView.collectionViewLayout as! BaseFlowLayout).configureFor(bounds: self.view.bounds)
        }, completion: nil)
        
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
    
    var tableMode: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureFor(bounds: CGRect) {
        
        if tableMode {
        
            minimumInteritemSpacing = 0
            sectionInset = .zero
            itemSize = CGSize(width: bounds.size.width, height: 60)
            
            return;
        }
        
        minimumInteritemSpacing = 17
        
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
