//
//  PageIndicator.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 04.08.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

@IBDesignable class PageIndicator: UIView {

    @IBInspectable var pagesCount: Int = 3 {
        didSet {
            setUpStackView()
        }
    }
    
    @IBInspectable var currentPage: Int = 0 {
        didSet {
            setUpStackView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    // MARK: - Private
    
    private let stackView = UIStackView()
}

private extension PageIndicator {
    
    func setUp() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(self)
            $0.height.equalTo(12)
        }
        
        setUpStackView()
    }
    
    func setUpStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        
        for dotImageView in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(dotImageView)
            dotImageView.removeFromSuperview()
        }
        
        for _ in 0 ..< pagesCount {
            let dotImageView = UIImageView()
            stackView.addArrangedSubview(dotImageView)
        }
        
        updateSelection()
    }
    
    func updateSelection() {
        for (i, dotImageView) in stackView.arrangedSubviews.enumerated() {
            (dotImageView as? UIImageView)?.image = (i == currentPage) ? R.image.pageDotSelected() : R.image.pageDot()
        }
    }
}
