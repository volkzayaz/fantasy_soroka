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

class SubscriptionViewController: UIViewController, MVVM_View {
    
    var viewModel: SubscriptionViewModel!
    
    @IBOutlet private weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = SubscriptionViewModel.Page.allCases.count
        }
    }
    
    @IBOutlet weak var plansStackView: UIStackView!
    @IBOutlet weak var seeOtherPlansButton: UIButton!
    @IBOutlet weak var subscribeButton: SecondaryButton!
    @IBOutlet weak var roundedView: UIView!
    
    var selectedIndex: Int = 1

    @IBAction func tryOffer1(_ sender: Any) {
        selectedIndex = 0
        selectView(view: plansStackView.arrangedSubviews[0])
    }
    
    @IBAction func tapOffer2(_ sender: Any) {
        selectedIndex = 1
        selectView(view: plansStackView.arrangedSubviews[1])
    }

    @IBAction func tapOffer3(_ sender: Any) {
        selectedIndex = 2
        selectView(view: plansStackView.arrangedSubviews[2])
    }
    
    func selectView(view: UIView) {
        plansStackView.arrangedSubviews.forEach { (x: UIView?) in x?.layer.borderColor = UIColor.clear.cgColor
        }
        
        view.layer.borderColor = R.color.textPinkColor()!.cgColor
        view.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.screenTitle
        
        view.addFantasyRoundedCorners()
        navigationController?.view.addFantasySubscriptionGradient()
    
        edgesForExtendedLayout = []
        
        let layout = featuresCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: featuresCollectionView.bounds.height)
        
        viewModel.plans.withLatestFrom(viewModel.showAllPlans) { ($0, $1) }
            .drive(onNext: { [unowned self] plans, showAllPlans in
                self.plansStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                plans.enumerated().map { index, plan -> UIView in
                    let result = subscriptionPlanView(index: index, plan: plan)
                    result.isHidden = index != 0 && !showAllPlans
                    return result
                }.forEach { self.plansStackView.addArrangedSubview($0) }
            }).disposed(by: rx.disposeBag)
        
        Driver.combineLatest(viewModel.plans, viewModel.showAllPlans)
            .map { $0.count < 2 || $1 }
            .drive(seeOtherPlansButton.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showAllPlans
            .drive(onNext: { [unowned self] showAllPlans in
                guard self.plansStackView.arrangedSubviews.count > 1 else { return }
                self.plansStackView.arrangedSubviews.suffix(from: 1)
                    .forEach { $0.isHidden = !showAllPlans }
            }).disposed(by: rx.disposeBag)
        
        subscribeButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pageControl.currentPage = viewModel.startPage.rawValue
        DispatchQueue.main.async {
            self.featuresCollectionView.scrollToItem(at: IndexPath(item: self.viewModel.startPage.rawValue, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    @IBAction func seeOtherPlans(_ sender: Any) {
        viewModel.seeOtherPlans()
    }
    
    @IBAction func subscribe(_ sender: Any) {
        viewModel.subscribe(planIndex: selectedIndex)
    }
    
    @IBAction func cancel(_ sender: Any) {
        viewModel.willCancel()
        NotificationCenter.default.post(name: NSNotification.Name("screenCancel"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}

private extension SubscriptionViewController {
    
    func subscriptionPlanView(index: Int, plan: SubscriptionPlan) -> UIView {
        switch (viewModel.style, index) {
        case (.style1, _):
            return SubscriptionPlanStyle1View(plan: plan) { [weak self] in
                self?.viewModel.subscribe(planIndex: index)
            }
        case (.style2, 0):
            return PrimarySubscriptionPlanStyle2View(plan: plan) { [weak self] in
                self?.viewModel.subscribe(planIndex: index)
            }
        case (.style2, _):
            return SubscriptionPlanStyle2View(plan: plan) { [weak self] in
                self?.viewModel.subscribe(planIndex: index)
            }
        }
    }
}

extension SubscriptionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentPoint = CGPoint(x: featuresCollectionView.contentOffset.x + featuresCollectionView.frame.width / 2, y:  featuresCollectionView.frame.height / 2)
        if let item = featuresCollectionView.indexPathForItem(at: contentPoint)?.item {
            pageControl.currentPage = item
        }
    }
}

extension SubscriptionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SubscriptionViewModel.Page.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let featureCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.featureCell, for: indexPath)
        featureCell?.setUp(page: SubscriptionViewModel.Page.allCases[indexPath.item])
        
        return featureCell ?? SubscriptionFeatureCollectionViewCell()
    }
}
