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

class FantasyListViewController: UIViewController, MVVM_View, UICollectionViewDelegateFlowLayout {
    
    var viewModel: FantasyListViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FantasyListViewModel.CardType>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyListCell,
                                          for: ip)!
        
        switch x {
            
        case .fantasy(let card, let hidden):
            cell.set(protectedCard: card)
            
            cell.viewedIndicator.isHidden = hidden
            
        case .empty(_):
            cell.backgroundColor = .init(fromHex: 0xF7F7FA)
        
        }
        
        return cell
        
    }, configureSupplementaryView: { [unowned self] (_, cv, kind, ip) in
        
        if let x = self.strongRef {
            return x
        }
        
        self.strongRef = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.daHeader, for: ip)!
        self.viewModel.cardTitle
            .do(afterNext: { (_) in
                cv.collectionViewLayout.invalidateLayout()
            })
            .drive(self.strongRef!.label.rx.attributedText)
            .disposed(by: self.strongRef!.rx.disposeBag)
        
        return self.strongRef!
    })
    
    var strongRef: DaHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(R.nib.fantasyListCell)
        collectionView.register(R.nib.daHeader, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.delegate = self
        
        viewModel.tableScrollEnabled
            .drive(collectionView.rx.isUserInteractionEnabled)
            .disposed(by: rx.disposeBag)

        viewModel.dataSource
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] ip in
                
                let x: FantasyListViewModel.CardType? = try? self.collectionView.rx.model(at: ip)
                
                guard case .fantasy(let model, _)? = x else {
                    return
                }
                
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let headerView = strongRef {
            // Layout to get the right dimensions
            headerView.layoutIfNeeded()
            
            // Automagically get the right height
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
            
            // return the correct size
            return CGSize(width: collectionView.frame.width, height: height)
        }
        
        // You need this because this delegate method will run at least
        // once before the header is available for sizing.
        // Returning zero will stop the delegate from trying to get a supplementary view
        return CGSize(width: 1, height: 1)
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

class DaHeader: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!

}
