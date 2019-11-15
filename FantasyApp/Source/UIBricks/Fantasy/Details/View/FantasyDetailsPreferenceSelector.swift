//
//  FantasyDetailsPreferenceSelector.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11/13/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyDetailsPreferenceSelector: UIView {
    var likesCount: Int = 0 {
        didSet {
            likesCountLabel.text = R.string.localizable.fantasyCardPreferenceCountTitle(likesCount)
        }
    }
    
    var dislikesCount: Int = 0 {
        didSet {
            dislikesCountLabel.text = R.string.localizable.fantasyCardPreferenceCountTitle(dislikesCount)
        }
    }
    
    var reaction: Fantasy.Card.Reaction = .neutral {
        didSet {
            configurePreferenceState(reaction)
        }
    }
    
    var didPressLike: (() -> ())?
    var didPressDislike: (() -> ())?
    
    private var likeImage = UIImageView(frame: .zero)
    private var likeButton = UIButton(frame: .zero)
    private var likeLabel = UILabel(frame: .zero)
    private var likesCountLabel = UILabel(frame: .zero)
    private var dislikeImage = UIImageView(frame: .zero)
    private var dislikeButton = UIButton(frame: .zero)
    private var dislikeLabel = UILabel(frame: .zero)
    private var dislikesCountLabel = UILabel(frame: .zero)
    private var equalButtonsWidth: NSLayoutConstraint!
    private var likeSelectedWidth: NSLayoutConstraint!
    private var dislikeSelectedWidth: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
        configureStyling()
        configurePreferenceState(reaction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureLayout()
        configureStyling()
        configurePreferenceState(reaction)
    }
    
    // MARK: - Configuration
    private func configureLayout() {
        [likeButton,
         likeImage,
         likeLabel,
         likesCountLabel,
         dislikeButton,
         dislikeImage,
         dislikeLabel,
         dislikesCountLabel].forEach { view in
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            likeButton.leftAnchor.constraint(equalTo: dislikeButton.rightAnchor, constant: 7),
            likeButton.rightAnchor.constraint(equalTo: rightAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 52),
            
            likeImage.widthAnchor.constraint(equalToConstant: 24),
            likeImage.heightAnchor.constraint(equalToConstant: 24),
            likeImage.leftAnchor.constraint(equalTo: likeButton.leftAnchor, constant: 14),
            likeImage.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            
            likeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            likeLabel.leftAnchor.constraint(equalTo: likeButton.leftAnchor, constant: 55),
            likeLabel.rightAnchor.constraint(equalTo: likeButton.rightAnchor, constant: -23),
            
            likesCountLabel.topAnchor.constraint(equalTo: likeLabel.bottomAnchor),
            likesCountLabel.leftAnchor.constraint(equalTo: likeLabel.leftAnchor),
            likesCountLabel.rightAnchor.constraint(equalTo: likeLabel.rightAnchor),
            
            dislikeButton.topAnchor.constraint(equalTo: topAnchor),
            dislikeButton.leftAnchor.constraint(equalTo: leftAnchor),
            dislikeButton.heightAnchor.constraint(equalToConstant: 52),
            
            dislikeImage.widthAnchor.constraint(equalToConstant: 24),
            dislikeImage.heightAnchor.constraint(equalToConstant: 24),
            dislikeImage.leftAnchor.constraint(equalTo: dislikeButton.leftAnchor, constant: 14),
            dislikeImage.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            
            dislikeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            dislikeLabel.leftAnchor.constraint(equalTo: dislikeButton.leftAnchor, constant: 55),
            dislikeLabel.rightAnchor.constraint(equalTo: dislikeButton.rightAnchor, constant: -23),
            
            dislikesCountLabel.topAnchor.constraint(equalTo: dislikeLabel.bottomAnchor),
            dislikesCountLabel.leftAnchor.constraint(equalTo: dislikeLabel.leftAnchor),
            dislikesCountLabel.rightAnchor.constraint(equalTo: dislikeLabel.rightAnchor),
        ])
        
        equalButtonsWidth = dislikeButton.widthAnchor.constraint(equalTo: likeButton.widthAnchor)
        likeSelectedWidth = likeButton.widthAnchor.constraint(equalToConstant: 52)
        dislikeSelectedWidth = dislikeButton.widthAnchor.constraint(equalToConstant: 52)
    }
    
    private func configureStyling() {
        likeImage.image = R.image.like()
        dislikeImage.image = R.image.dislike()
        
        likeButton.setTitle(R.string.localizable.fantasyCardLikeButton(), for: .normal)
        likeButton.backgroundColor = .fantasyLightGrey
        likeButton.setTitleColor(.fantasyPink, for: .normal)
        likeButton.titleLabel?.font = .boldFont(ofSize: 16)
        likeButton.clipsToBounds = true
        likeButton.layer.cornerRadius = 26.0
        likeButton.addTarget(self, action: #selector(likeCard(_:)), for: .touchUpInside)

        dislikeButton.setTitle(R.string.localizable.fantasyCardDislikeButton(), for: .normal)
        dislikeButton.backgroundColor = .fantasyLightGrey
        dislikeButton.setTitleColor(.fantasyPink, for: .normal)
        dislikeButton.titleLabel?.font = .boldFont(ofSize: 16)
        dislikeButton.clipsToBounds = true
        dislikeButton.layer.cornerRadius = 26.0
        dislikeButton.addTarget(self, action: #selector(dislikeCard(_:)), for: .touchUpInside)
        
        likeLabel.text = R.string.localizable.fantasyCardLikedTitle()
        likeLabel.textColor = .fantasyPink
        likeLabel.font = .boldFont(ofSize: 16)

        dislikeLabel.text = R.string.localizable.fantasyCardDislikedTitle()
        dislikeLabel.textColor = .fantasyPink
        dislikeLabel.font = .boldFont(ofSize: 16)

        dislikesCountLabel.textColor = .fantasyBlack
        dislikesCountLabel.font = .regularFont(ofSize: 16)
        dislikesCountLabel.adjustsFontSizeToFitWidth = true

        likesCountLabel.textColor = .fantasyBlack
        likesCountLabel.font = .regularFont(ofSize: 16)
        likesCountLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func configurePreferenceState(_ reaction: Fantasy.Card.Reaction) {
        switch reaction {
        case .like:
            dislikeLabel.isHidden = true
            dislikesCountLabel.isHidden = true
        case .dislike:
            likeLabel.isHidden = true
            likesCountLabel.isHidden = true
        default:
            dislikeLabel.isHidden = true
            dislikesCountLabel.isHidden = true
            likeLabel.isHidden = true
            likesCountLabel.isHidden = true
        }

        likeButton.setTitle(reaction == .neutral ? R.string.localizable.fantasyCardLikeButton() : "",
                            for: .normal)
        likeButton.backgroundColor = reaction == .like ? .preferenceButtonSelected : .fantasyLightGrey

        dislikeButton.setTitle(reaction == .neutral ? R.string.localizable.fantasyCardDislikeButton() : "",
                               for: .normal)
        dislikeButton.backgroundColor = reaction == .dislike ? .preferenceButtonSelected : .fantasyLightGrey

        animatePreferenceChange(reaction)
    }
    
    // MARK: - Actions
    @objc private func likeCard(_ sender: Any) {
        didPressLike?()
    }

    @objc private func dislikeCard(_ sender: Any) {
        didPressDislike?()
    }
    
    // MARK: - Animation
    private func animatePreferenceChange(_ reaction: Fantasy.Card.Reaction) {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            self.equalButtonsWidth.isActive = reaction == .neutral
            self.likeSelectedWidth.isActive = reaction != .like
            self.dislikeSelectedWidth.isActive = reaction != .dislike
            self.layoutIfNeeded()
        }) { [weak self] _ in
            self?.dislikeLabel.isHidden = reaction != .dislike
            self?.dislikesCountLabel.isHidden = reaction != .dislike
            self?.likeLabel.isHidden = reaction != .like
            self?.likesCountLabel.isHidden = reaction != .like
        }
    }
}
