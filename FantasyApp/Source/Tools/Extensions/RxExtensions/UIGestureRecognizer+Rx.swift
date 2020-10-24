//
//  UIGestureRecognizer+Rx.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 07.08.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIGestureRecognizer {
    
    var isEnabled: RxCocoa.Binder<Bool> {
        return Binder(base, binding: { (gestureRecognizer, isEnabled) in
            gestureRecognizer.isEnabled = isEnabled
        })
    }
}
