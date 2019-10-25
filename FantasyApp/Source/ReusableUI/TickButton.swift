//
//  TickButton.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/17/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class TickButton: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setTitle("", for: .normal)
        self.setTitle("", for: .selected)
        
        self.setImage(R.image.checkBoxNonActive(), for: .normal)
        self.setImage(R.image.checkBoxActive(), for: .selected)
        
        self.addTarget(self, action: #selector(pip), for: .touchUpInside)
    }
    
    @objc private func pip() {
        isSelected = !isSelected
    }
    
}
