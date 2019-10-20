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
    
    @IBOutlet weak var locationMessageLabel: UILabel!
    @IBOutlet weak var profilesCarousel: iCarousel! {
        didSet {
            profilesCarousel.type = .custom
            profilesCarousel.isPagingEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        
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
                
                [self.profilesCarousel, self.locationMessageLabel]
                    .forEach { $0?.isHidden = true }
                
                switch mode {
                case .profiles:
                    self.profilesCarousel.isHidden = false
                    
                case .noLocationPermission:
                    self.locationMessageLabel.isHidden = false
                    self.locationMessageLabel.text = "Can you share your location? We really need it"
                    
                case .absentCommunity(let nearestCity):
                    self.locationMessageLabel.isHidden = false
                    if let nearestCity = nearestCity {
                        self.locationMessageLabel.text = "Fantasy is not yet available at \(nearestCity). Stay tuned, we'll soon be there"
                    }
                    else {
                        self.locationMessageLabel.text = "We can't figure out where are you at the moment. Feel free to send us your City at fantasyapp@email.com. Or use teleport"
                    }
                    
                case .noSearchPreferences:
                    self.locationMessageLabel.isHidden = false
                    self.locationMessageLabel.text = "Before we search, set your searching preferences"
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

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
