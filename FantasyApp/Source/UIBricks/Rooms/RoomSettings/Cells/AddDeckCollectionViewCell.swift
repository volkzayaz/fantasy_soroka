//
//  AddCollectionViewCell.swift
//  FantasyApp
//
//  Created by Максим Сорока on 18.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class AddDeckCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifire = "AddCell"
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        imageView.image = R.image.invite()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    private let addLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Add"
        label.font = .boldFont(ofSize: 20)
        label.textColor = .fantasyPink
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 17
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .fantasyGrey
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDeckCollectionViewCell {
    private func setupConstraints() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(addLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            
        ])
    }
}
