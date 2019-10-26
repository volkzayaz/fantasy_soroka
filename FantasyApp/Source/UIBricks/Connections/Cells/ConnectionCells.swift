//
//  IncommingConnectionCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import RxSwift

class IncommingConnectionCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var inviteTypeStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func set(connection: ConnectedUser) {
        
        nameLabel.text = connection.user.bio.name
        
        ImageRetreiver.imageForURLWithoutProgress(url: connection.user.bio.photos.avatar.url)
            .map { $0 ?? R.image.noPhoto() }
            .drive(avatarImageView.rx.image)
            .disposed(by: bag)
        
        inviteTypeStackView.subviews.forEach { $0.removeFromSuperview() }
        
        connection.connectTypes
            .map { UIImageView(image: $0.incommingRequestImage) }
            .forEach(inviteTypeStackView.addArrangedSubview)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bag = DisposeBag()
    }
    
    var bag = DisposeBag()
    
}

class OutgoingConnectionCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var inviteTypeStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func set(connection: ConnectedUser) {
        
        nameLabel.text = connection.user.bio.name
        
        ImageRetreiver.imageForURLWithoutProgress(url: connection.user.bio.photos.avatar.url)
            .map { $0 ?? R.image.noPhoto() }
            .drive(avatarImageView.rx.image)
            .disposed(by: bag)
        
        inviteTypeStackView.subviews.forEach { $0.removeFromSuperview() }
        
        connection.connectTypes
            .map { UIImageView(image: $0.outgoingRequestImage) }
            .forEach(inviteTypeStackView.addArrangedSubview)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bag = DisposeBag()
    }
    
    var bag = DisposeBag()
    
}
