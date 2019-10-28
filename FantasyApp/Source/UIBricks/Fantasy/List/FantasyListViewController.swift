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
    
    private var animator = FantasyDetailsTransitionAnimator()
    
    var viewModel: FantasyListViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionTitleLabel: UILabel!
    
    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Fantasy.Card>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyListCell,
                                          for: ip)!
        
        cell.setCard(fantasy: x)
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (collectionView.collectionViewLayout as! BaseFlowLayout).configureFor(bounds: view.bounds)
        
        collectionTitleLabel.text = viewModel.title
        
        viewModel.dataSource
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.modelSelected(Fantasy.Card.self)
            .subscribe(onNext: { [unowned self] x in
                self.viewModel.cardTapped(card: x)
            })
            .disposed(by: rx.disposeBag)
    }
    
}

private extension FantasyListViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}


extension FantasyListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let ratio = view.frame.height / FantasyDetailsViewController.minBackgroundImageHeight
        let originFrame = CGRect(x: (UIScreen.main.bounds.width - (UIScreen.main.bounds.width * ratio)) / 2.0,
                                 y: (UIScreen.main.bounds.height - (UIScreen.main.bounds.height * ratio)) / 2.0,
                                 width: UIScreen.main.bounds.width * ratio,
                                 height: UIScreen.main.bounds.height * ratio)

        animator.originFrame = originFrame
        animator.presenting = true
        
        return animator
    }
}
