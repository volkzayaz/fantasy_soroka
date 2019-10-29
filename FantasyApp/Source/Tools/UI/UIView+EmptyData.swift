//
//  UIView+EmptyData.swift
//  Grasshopper
//
//  Created by Vlad Soroka on 12/18/16.
//  Copyright © 2016 Grasshopper. All rights reserved.
//

import Foundation
import RxCocoa
import SnapKit

struct EmptyState {
    let isEmpty: Bool
    let emptyView: UIView
}

extension UIView {
    
    /**
     *  @discussion - setOnly property for binding Driver to emptyState property.
     */
    var bindEmptyStateTo: Driver<EmptyState> {
        get { fatalError("bindEmptyStateTo is setOnly property") }
        set {
            
            newValue.drive (onNext: { [unowned self] indicator in
                self.emptyState = indicator
            })
                .disposed(by: self.rx.disposeBag)
            
        }
    }
    
    /**
     * @discussion - you can also enable/disable animation manually
     */
    var emptyState : EmptyState {
        get {
            return EmptyState(isEmpty: self.emptyView(content: UIView()).isHidden, emptyView: UIView())
        }
        set {
            let pv = self.emptyView(content: newValue.emptyView)
            pv.superview?.isUserInteractionEnabled = !pv.isHidden
            
            UIView.animate(withDuration: 0.3) {
                pv.alpha = newValue.isEmpty ? 1 : 0
            }
            
        }
    }
}


extension UIView {
    
    ///not the best solution, though.
    ///On heavy layots recursive search for view with tag might be expensive
    fileprivate var emptyViewHash: Int {
        return "com.Grasshopper.emptyHash".hash
    }
    
    fileprivate func emptyView(content: UIView) -> UIView {
        
        if let ev = self.subviews.filter({ $0.tag == self.emptyViewHash }).first {
            return ev
        }
        
        
        let container = UIView()
        container.isUserInteractionEnabled = true
        container.alpha = 0;
        container.tag = self.emptyViewHash;
        
        container.addSubview(content)
        self.addSubview(container)
        
        if self is UIScrollView {
            self.positionOnScrollView(container: container,
                                      view: content)
        }
        else {
            self.positionOnStaticView(container: container,
                                      view: content)
        }
        
        return container
    }
    
    func positionOnScrollView(container: UIView,
                              view: UIView) {
        
        guard let scrollView = self as? UIScrollView else {
            fatalError("self is not a scrollView subclass")
        }
        
        let _ =
        scrollView.rx.sentMessage(#selector(UIView.layoutSubviews))
            .subscribe(onNext: { [unowned sv = scrollView] (_) in
                
                sv.bringSubviewToFront(container)
                
                container.frame = CGRect(origin: sv.contentOffset, size: sv.frame.size)
                view.center = CGPoint( x: container.bounds.midX,
                                       y: container.bounds.midY)
                
            })
        
    }
    
    func positionOnStaticView(container: UIView,
                              view: UIView) {
        
        view.snp.makeConstraints { (make) in
            make.center.equalTo(container)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
    }
    
    
    
}
