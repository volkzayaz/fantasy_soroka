//
//  DiscoverProfileViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import iCarousel

extension PrimaryButton {
    func addLightGrayColorStyle () {
        backgroundColor = R.color.listBackgroundColor()
                  tintColor = R.color.textPinkColor()
                  titleFont = UIFont.regularFont(ofSize: 16)
                  mode = .normal
    }
}

class DiscoverProfileViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: DiscoverProfileViewModel! = DiscoverProfileViewModel(router: .init(owner: self))
    
    @IBOutlet weak var profilesCarousel: iCarousel! {
        didSet {
            profilesCarousel.type = .custom
            profilesCarousel.isPagingEnabled = true
        }
    }

    // Location section
    @IBOutlet weak var allowGeolocationView: UIView! {
        didSet {
            allowGeolocationView.addFantasyRoundedCorners()
        }
    }
    @IBOutlet weak var cityNotActiveView: UIView! {
        didSet {
            cityNotActiveView.addFantasyRoundedCorners()
        }
    }
    @IBOutlet weak var notActiveCityNameLabel: UILabel!
    @IBOutlet weak var notAllowButton: PrimaryButton! {
        didSet {
            notAllowButton.addLightGrayColorStyle()
        }
    }
    @IBOutlet weak var inviteFriendsButton: PrimaryButton! {
        didSet {
            inviteFriendsButton.addLightGrayColorStyle()
        }
    }

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyTripleGradient()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(presentFilter))
        
        viewModel.profiles
            .subscribe(onNext: { [weak self] (_) in
                self?.profilesCarousel.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.mode
            .drive(onNext: { [unowned self] (mode) in

                self.hideView(self.cityNotActiveView)
                self.hideView(self.allowGeolocationView)
                self.profilesCarousel.isHidden = true

                switch mode {
                case .profiles:
                    self.profilesCarousel.isHidden = false
                    
                case .noLocationPermission:
                    self.showView(self.allowGeolocationView)

                case .absentCommunity(let nearestCity):
                    self.showView(self.cityNotActiveView)

                    let cityName = nearestCity ?? "Your city"
                    self.notActiveCityNameLabel.attributedText = NSAttributedString(string: "\(cityName) will be activated when it reaches")

                case .noSearchPreferences:
                    self.viewModel.presentFilter()
//                    self.locationMessageLabel.isHidden = false
//                    self.locationMessageLabel.text = "Before we search, set your searching preferences"
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
}

// MARK:- Views Management

extension DiscoverProfileViewController {

    private func showView(_ viewToShow: UIView) {

        view.addSubview(viewToShow)

        viewToShow.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
        }

    }

    private func hideView(_ view: UIView) {
        view.removeFromSuperview()
    }
}

// MARK:- Actions

extension DiscoverProfileViewController {

    @IBAction func notAllowLocationClick(_ sender: Any) {
        viewModel.notAllowLocationService()
    }

    @IBAction func allowLocationClick(_ sender: Any) {
        viewModel.allowLocationService()
    }

    @IBAction func inviteFriendsClick(_ sender: Any) {
        viewModel.inviteFriends()
    }

    @IBAction func joinActiveCityClick(_ sender: Any) {
        viewModel.joinActiveCity()
    }
}

// MARK:- iCarouselDelegate

extension DiscoverProfileViewController: iCarouselDelegate, iCarouselDataSource {

    @objc func presentFilter() {
        viewModel.presentFilter()
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return viewModel.profiles.value.count + 1 /// 1 stands for "No new fantasy seekers today" placeholder
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        guard let profile = viewModel.profiles.value[safe: index] else {
            
            let noFantasySeekersPlaceholder = UIView()
            
            noFantasySeekersPlaceholder.backgroundColor = .blue
            
            let label = UILabel()
            label.text = "No More Fantasy seekers. Invite friends or change filter"
            label.sizeToFit()
            
            noFantasySeekersPlaceholder.addSubview(label)
            
            return noFantasySeekersPlaceholder
        }
        
        let view = UIView(frame: carousel.bounds)
        
        let label = UILabel()
        label.text = profile.bio.name
        label.sizeToFit()
        
        view.addSubview(label)
        view.backgroundColor = index % 2 == 0 ? .red : .green
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel,
                  valueFor option: iCarouselOption,
                  withDefault value: CGFloat) -> CGFloat {
        
        switch option {
        case .wrap: return 0
        case .spacing: return 0.5
        case .visibleItems: return 3
        case .radius: return 220
            
        default: return value
            
        }

        
    }
    
    func carousel(_ carousel: iCarousel,
                  itemTransformForOffset offset: CGFloat,
                  baseTransform transform: CATransform3D) -> CATransform3D {
        let MAX_SCALE: Float = 1
        let MAX_Shift: Float = 25
        let distance: Float = 40
        
        let shift: Float = fminf(1, fmaxf(-1, Float(offset)))
        let scale: CGFloat = CGFloat(1 + (1 - abs(shift)) * (MAX_SCALE - 1))
        let z:     Float = -fminf(1, abs(Float(offset))) * distance
        
        let newTransform = CATransform3DTranslate(transform,
                                                  offset * carousel.itemWidth + CGFloat(shift * MAX_Shift),
                                                  0,
                                                  CGFloat(z));
        return CATransform3DScale(newTransform, scale, scale, scale);

    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {

        guard let profile = viewModel.profiles.value[safe: index] else {
            return
        }
        
        viewModel.profileSelected(profile)
        
    }
    
}
