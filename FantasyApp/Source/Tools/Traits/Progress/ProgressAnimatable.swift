//
//  AnimationStatus.swift
//     
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016
//  All rights reserved.

import RxSwift

protocol ProgressAnimatable {
    
    func setLoadingStatus(_ status: Bool)
    
}

extension UIViewController: ProgressAnimatable {
    
    func setLoadingStatus(_ status: Bool) {
    
        if self.isViewLoaded {
            view.indicateProgress = status
        } else {
            let _ = rx
                .sentMessage(#selector(UIViewController.viewDidLoad))
                .subscribe( onNext: { [unowned self] _ in self.view.indicateProgress = status })
        }
        
    }
    
}

extension UIView: ProgressAnimatable {
    
    func setLoadingStatus(_ status: Bool) {
        
        self.indicateProgress = status
        
    }
    
}
