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
    
    var offers: [SubscriptionOffer] = []
    
    var selectedIndex: Int = 1
    
    @IBOutlet weak var mostPopularView: UIView!
    
    @IBOutlet weak var offferView1: UIView!
    @IBOutlet weak var priceLabel1: UILabel!
    @IBOutlet weak var durationLabel1: UILabel!
    @IBOutlet weak var dailyCharge1: UILabel!
    @IBOutlet weak var savePercent1: UILabel!
    
    @IBAction func tryOffer1(_ sender: Any) {
        selectedIndex = 0
        selectView(view: offferView1, label: priceLabel1)
    }
    
    @IBOutlet weak var offerView2: UIView!
    @IBOutlet weak var priceLabel2: UILabel!
    @IBOutlet weak var durationLabel2: UILabel!
    @IBOutlet weak var dailyCharge2: UILabel!
    @IBOutlet weak var savePercent2: UILabel!
    
    @IBAction func tapOffer2(_ sender: Any) {
        selectedIndex = 1
        selectView(view: offerView2, label: priceLabel2)
    }
    
    @IBOutlet weak var offerView3: UIView!
    @IBOutlet weak var priceLabel3: UILabel!
    @IBOutlet weak var durationLabel3: UILabel!
    @IBOutlet weak var dailyCharge3: UILabel!
    @IBOutlet weak var savePercent3: UILabel!
    
    @IBAction func tapOffer3(_ sender: Any) {
        //viewModel.subscribe(offer: offers[2])
        selectedIndex = 2
        selectView(view: offerView3, label: priceLabel3)
    }
    
    func selectView(view: UIView, label: UILabel) {
        
        [offferView1, offerView2, offerView3].forEach { (x: UIView?) in x?.layer.borderColor = UIColor.clear.cgColor
        }

        [priceLabel1, priceLabel2, priceLabel3].forEach { (x: UILabel?) in x?.textColor = R.color.textBlackColor()
        }
        
        view.layer.borderColor = R.color.textPinkColor()!.cgColor
        view.layer.borderWidth = 1
        label.textColor = R.color.textPinkColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = R.string.localizable.subscriptionNavigationTitle()
        
        roundedView.addFantasyRoundedCorners()
        navigationController?.view.addFantasySubscriptionGradient()
    
        edgesForExtendedLayout = []
     
        [priceLabel1,
         durationLabel1,
         dailyCharge1,
         savePercent1,
         priceLabel2,
         durationLabel2,
         dailyCharge2,
         savePercent2,
         priceLabel3,
         durationLabel3,
         dailyCharge3,
         savePercent3]
            .forEach { $0?.text = "" }
        
        viewModel.offers.drive(onNext: { [unowned self] x in
            
            guard x.count > 0 else {
                return
            }
            
            self.offers = x
            
            self.priceLabel1.text = x[0].plan.price
            self.durationLabel1.text = x[0].plan.duration
            self.dailyCharge1.text = x[0].plan.dailyCharge
            self.savePercent1.text = x[0].discount
            
            self.priceLabel2.text = x[1].plan.price
            self.durationLabel2.text = x[1].plan.duration
            self.dailyCharge2.text = x[1].plan.dailyCharge
            self.savePercent2.text = x[1].discount
            
            self.priceLabel3.text = x[2].plan.price
            self.durationLabel3.text = x[2].plan.duration
            self.dailyCharge3.text = x[2].plan.dailyCharge
            self.savePercent3.text = x[2].discount
            
        })
            .disposed(by: rx.disposeBag)
        
        selectView(view: offerView2, label: priceLabel2)
        
        mostPopularView.backgroundColor = .clear;
        mostPopularView.addFantasySubscriptionGradient(radius: true)
        
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
        viewModel.subscribe(offer: offers[selectedIndex])
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
        
        pageControl.currentPage = min(3, x)
        
    }
    
}
