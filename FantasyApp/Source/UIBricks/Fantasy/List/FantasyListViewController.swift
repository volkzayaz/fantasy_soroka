//
//  FantasyListViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class FantasyListViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyListViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionTitleLabel: UILabel! {
        didSet {
            collectionTitleLabel.text = ""
        }
    }
    @IBOutlet weak var collectionNumberLabel: UILabel! {
        didSet {
            collectionNumberLabel.text = ""
        }
    }

    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ProtectedEntity<Fantasy.Card>>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyListCell,
                                          for: ip)!
        
        cell.set(protectedCard: x)
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(R.nib.fantasyListCell)
        //view.backgroundColor = .red
        
        collectionTitleLabel.text = viewModel.title

        viewModel.cardNumberText
            .drive(collectionNumberLabel.rx.attributedText)
            .disposed(by: rx.disposeBag)

        viewModel.dataSource
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] ip in
                
                let model: ProtectedEntity<Fantasy.Card> = try! self.collectionView.rx.model(at: ip)
                let sourceRect = self.collectionView.convert(self.collectionView.cellForItem(at: ip)!.frame,
                                                            to: nil)
                
                self.viewModel.cardTapped(card: model.entity,
                                          sourceFrame: sourceRect)
            })
            .disposed(by: rx.disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        (collectionView.collectionViewLayout as! BaseFlowLayout).configureFor(bounds: view.bounds)
    }
    
}

extension FantasyListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        viewModel.animator.presenting = false
        return viewModel.animator
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        viewModel.animator.presenting = true
        return viewModel.animator
    }
}
