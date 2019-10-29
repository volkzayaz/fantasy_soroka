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

class DiscoverProfileViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: DiscoverProfileViewModel! = DiscoverProfileViewModel(router: .init(owner: self))
    
    @IBOutlet weak var profilesCarousel: iCarousel! {
        didSet {
            profilesCarousel.type = .custom
            profilesCarousel.isPagingEnabled = true
        }
    }

    // Location section
    @IBOutlet weak var noFilterView: UIView!
    @IBOutlet weak var allowGeolocationView: UIView!
    @IBOutlet weak var cityNotActiveView: UIView!
    @IBOutlet weak var goToSettingsView: UIView!
    @IBOutlet weak var notActiveCityNameLabel: UILabel!

    func enableFilter(_ enable: Bool) {

        guard enable else {
            navigationItem.rightBarButtonItem = nil
            return
        }

        let item = UIBarButtonItem(title: "Filters", style: .done, target: self, action: #selector(presentFilter))
        item.applyFantasyAttributes()
        navigationItem.rightBarButtonItem = item
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure UI
        noFilterView.addFantasyRoundedCorners()
        goToSettingsView.addFantasyRoundedCorners()
        cityNotActiveView.addFantasyRoundedCorners()
        allowGeolocationView.addFantasyRoundedCorners()
        view.addFantasyTripleGradient()

        viewModel.profiles
            .subscribe(onNext: { [weak self] (_) in
                self?.profilesCarousel.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.mode
            .drive(onNext: { [unowned self] (mode) in

                self.hideView(self.cityNotActiveView)
                self.hideView(self.allowGeolocationView)
                self.hideView(self.goToSettingsView)
                self.hideView(self.noFilterView)
                self.enableFilter(true)

                self.profilesCarousel.isHidden = true

                switch mode {
                case .profiles:
                    self.profilesCarousel.isHidden = false

                case .noLocationPermission:
                    self.enableFilter(false)
                    self.showView(self.goToSettingsView)

                case .absentCommunity(let nearestCity):
                    self.showView(self.cityNotActiveView)

                    let cityName = nearestCity ?? "Your city"
                    let text = "\(cityName) will be activated when it reaches"
                    let attr = NSMutableAttributedString(string: text)

                    attr.addAttribute(NSAttributedString.Key.foregroundColor, value: R.color.textPinkColor()!,
                                      range: NSMakeRange(0, cityName.count))
                    self.notActiveCityNameLabel.attributedText = attr

                case .noSearchPreferences:
                    self.showView(self.noFilterView)
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

    @IBAction func goToSettings(_ sender: Any) {
        viewModel.goToSettings()
    }

    @IBAction func filtersClick(_ sender: Any) {
        viewModel.presentFilter()
    }

    @objc func presentFilter() {
        viewModel.presentFilter()
    }
}

// MARK:- iCarouselDelegate

extension DiscoverProfileViewController: iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return viewModel.profiles.value.count + 1 /// 1 stands for "No new fantasy seekers today" placeholder
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        guard let profile = viewModel.profiles.value[safe: index] else {
            
            let v = NoUsersCarouselView(frame: carousel.bounds)
            v.delegate = self

            return v
        }
        
        let view = UserCarouselView(frame: carousel.bounds)
        view.setUser(profile)

        return view
        
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap: return 0
        case .spacing: return 0.5
        case .visibleItems: return 3
        case .radius: return 220
            
        default: return value
        }
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {

        let MAX_SCALE: Float = 1
        let MAX_Shift: Float = 25
        let distance: Float = 40
        let multiplier: CGFloat = 1.0

        let shift: Float = fminf(1, fmaxf(-1, Float(offset)))
        let scale: CGFloat = CGFloat(1 + (1 - abs(shift)) * (MAX_SCALE - 1))
        let z:     Float = -fminf(1, abs(Float(offset))) * distance
        
        let newTransform = CATransform3DTranslate(transform,
                                                  offset * (carousel.itemWidth * multiplier) + CGFloat(shift * MAX_Shift),
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

//MARK:- NoUsersCarouselViewDelegate

extension DiscoverProfileViewController: NoUsersCarouselViewDelegate {

    func inviteFriends() {
        viewModel.inviteFriends()
    }

    func showFilters() {
        viewModel.presentFilter()
    }
}
