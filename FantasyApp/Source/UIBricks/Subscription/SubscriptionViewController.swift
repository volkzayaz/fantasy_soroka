//
//  SubscriptionViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.01.2020.
//Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SubscriptionViewController: UITableViewController, MVVM_View {
    
    var viewModel: SubscriptionViewModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var subscribeButton: SecondaryButton!
    @IBOutlet weak var roundedView: UIView!
    
    @IBOutlet weak var pricaeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Get Membership"
        
        roundedView.addFantasyRoundedCorners()
        navigationController?.view.addFantasySubscriptionGradient()
    
        edgesForExtendedLayout = []
     
        viewModel.price
            .drive(pricaeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
    }
    
    var once = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if once { return }
        once = true
        
        scrollView.setContentOffset(.init(x: scrollView.bounds.size.width * CGFloat(viewModel.startPage.rawValue),
                                          y: 0),
                                    animated: false)
        pageControl.currentPage = viewModel.startPage.rawValue
    }
    
    @IBAction func subscribe(_ sender: Any) {
        viewModel.subscribe()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("screenCancel"), object: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SubscriptionViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView == self.scrollView else { return }
        
        let x = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        pageControl.currentPage = min(4, x)
        
    }
    
}
