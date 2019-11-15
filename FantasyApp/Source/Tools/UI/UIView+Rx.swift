//
//  UIView+Rx.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 11/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
     
    public func hidden(in stackView: UIStackView) -> Binder<Bool> {
        return Binder(self.base) { [weak sv = stackView] view, isHidden in
            
            UIView.animate(withDuration: 0.5,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.9,
                                   initialSpringVelocity: 1,
                                   options: [],
                                   animations: {
                                    
                                    view.isHidden = isHidden
                                    view.alpha = isHidden ? 0 : 1
                                    
                                    sv?.layoutIfNeeded()
                                },
            completion: nil)
            
        }
    }

}

