//
//  NoChatView.swift
//  FantasyApp
//
//  Created by Максим Сорока on 29.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class NoChatView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Chat Started"
        label.font = .boldFont(ofSize: 25)
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Invite someone and start a chat"
        label.font = .regularFont(ofSize: 17)
        label.textColor = .gray
        
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "noChatStarted")
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let inviteButton: SecondaryButton = {
        let button = SecondaryButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal)
        
        return button
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 8
        
        
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        inviteButton.addTarget(self, action: #selector(shareLink), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        addSubview(stackView)
        addSubview(imageView)
        addSubview(inviteButton)
        
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
           
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 230),
            
            imageView.topAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            imageView.bottomAnchor.constraint(equalTo: inviteButton.topAnchor, constant: -10),
            
            inviteButton.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -30),
            inviteButton.heightAnchor.constraint(equalToConstant: 55),
            inviteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),
            inviteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -55)
          
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: - Actions

extension NoChatView {
    
    @objc func shareLink() {
        print("Share Link")
    }
    
}
