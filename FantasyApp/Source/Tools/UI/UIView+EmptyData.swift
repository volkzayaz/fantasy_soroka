//
//  UIView+EmptyData.swift
//  Grasshopper
//
//  Created by Vlad Soroka on 12/18/16.
//  Copyright © 2016 Grasshopper. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import SnapKit

extension Reactive where Base: EmptyView {
    
    var isEmpty: Binder<Bool> {
        return Binder(self.base) { view, isEmpty in
            view.isEmpty = isEmpty
        }
    }

    var emptyView: Binder<UIView> {
        return Binder(self.base) { view, emptyView in
            view.emptyView = emptyView
        }
    }
    
}

class EmptyView: UIView {

    /**
     * @discussion - you can also enable/disable animation manually
     */
    
    var isEmpty: Bool = false {
        didSet {
            
            UIView.animate(withDuration: 0.3) {
                self.emptyView?.alpha = self.isEmpty ? 1 : 0
            }
        }
    }
    
    var emptyView: UIView? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            
            guard let newView = emptyView else { return }
            
            newView.alpha = 0
            addSubview(newView)
            
            newView.snp.makeConstraints { (make) in
                make.center.equalTo(self)
            }
        }
    }
    
    var rx: Reactive<EmptyView> {
        return Reactive(self)
    }
}

extension UIView {
    
    func addEmptyView() -> EmptyView {
        let ev = EmptyView()
        
        if let s = self as? UITableView {
            s.backgroundView = ev
        }
        else if let s = self as? UICollectionView {
            s.backgroundView = ev
        }
        else {
            addSubview(ev)
        }
        
        return ev
    }
    
}
