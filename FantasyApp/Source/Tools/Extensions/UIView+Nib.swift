//
//  UIView+Nib.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 19.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

extension UIView {
    
    func loadFromNib() {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: String(describing: type(of:self)), bundle: bundle)
        let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
        }
    }
}

