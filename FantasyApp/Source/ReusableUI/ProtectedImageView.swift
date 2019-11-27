//
//  ProtectedImageView.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 11/3/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import ScreenShieldKit
import RxSwift
import SnapKit

class ProtectedImageView: UIView {
    
    var regularImageView: UIImageView!
    var protectedImageView: SSKProtectedImageView!
    
    var bag = DisposeBag()
    
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    
    func set(imageURL: String, isProtected: Bool, errorPlaceholder: UIImage? = nil) {
        
        regularImageView.isHidden = isProtected
        protectedImageView.isHidden = !isProtected
        
        if !isProtected {
    
            ImageRetreiver.imageForURLWithoutProgress(url: imageURL)
                .trackView(viewIndicator: indicator)
                .map { $0 ?? errorPlaceholder }
                .bind(to: regularImageView.rx.image(transitionType: CATransitionType.fade.rawValue))
                .disposed(by: bag)
            
        }
        
        ImageRetreiver.imageForURLWithoutProgress(url: imageURL)
            .map { $0 ?? errorPlaceholder }
            .trackView(viewIndicator: indicator)
            .subscribe(onNext: { [weak self] (x) in
                
                let transition = CATransition()
                transition.duration = 0.25
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                transition.type = CATransitionType.fade
                
                self?.protectedImageView.layer.add(transition, forKey: kCATransition)

                self?.protectedImageView.image = x
            })
            .disposed(by: bag)
            
    }
    
    func reset() {
        bag = DisposeBag()
        
        regularImageView.image = nil
        protectedImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    
    func commonInit() {
        
        regularImageView = .init()
        regularImageView.contentMode = .scaleAspectFill
        addSubview(regularImageView)
        regularImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        protectedImageView = .init(image: nil)
        addSubview(protectedImageView)
        protectedImageView.resizeMode = .scaleAspectFill
        
        let placeholder = UIImageView(image: R.image.screenShield_placeholder()!)
        placeholder.contentMode = .scaleAspectFill
        protectedImageView.screenCaptureView.addSubview(placeholder)
        
        placeholder.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        protectedImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
     
        indicator.asDriver()
            .drive(onNext: { [weak self] (loading) in
                self?.setLoadingStatus(loading)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}
