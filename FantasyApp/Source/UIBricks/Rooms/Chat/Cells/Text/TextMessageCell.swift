//
//  TextMessageCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TextBubleView: UIView {
    
    @IBOutlet weak var text: UITextView! {
        didSet {
            text.font = MessageStyle.font
            text.backgroundColor = .clear
        }
    }
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bubble: UIView! {
        didSet {
            bubble.layer.cornerRadius = 18
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 15
            avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapOnAvatar")))
        }
    }
    
    var viewModel: ChatViewModel!
    
    var message: Room.Message! {
        didSet {

            text.text = message.text
            
            date.text = message.createdAt.toMessageTimestampString()
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        text.textContainerInset = .zero
        text.textContainer.lineFragmentPadding = 0
    }
    
    
    @objc func tapOnAvatar() {
        viewModel.presentPeer()
    }
    
}

class OwnMessageCell: UITableViewCell {
    
    weak var textBubble: TextBubleView!
    
    var position: MessageCellPosition!
    var message: Room.Message! {
        didSet {
            textBubble.message = message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let x = R.nib.textMessageCell(owner: nil)
        addSubview(x!)
        textBubble = x
        
        textBubble.bubble.backgroundColor = .init(fromHex: 0xd364b1)
        textBubble.bubble.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        textBubble.text.textColor = .title
        textBubble.date.textColor = .init(white: 1, alpha: 0.8)
     
        textBubble.avatarImageView.isHidden = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = CGRect(x: bounds.size.width - MessageStyle.sideInset - position.totalWidth,
                          y: MessageStyle.upDownInset,
                          width: position.totalWidth,
                          height: position.bubbleSize.height)
        textBubble.frame = rect
        
    }
    
}

class OtherMessageCell: UITableViewCell {
    
    weak var textBubble: TextBubleView!
    
    var position: MessageCellPosition!
    var message: Room.Message! {
        didSet {
            textBubble.message = message
        }
    }
    
    private let bag = DisposeBag()
    var avatar: Driver<UIImage>! {
        didSet {
            avatar
                .drive(textBubble.avatarImageView.rx.image)
                .disposed(by: bag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let x = R.nib.textMessageCell(owner: nil)
        addSubview(x!)
        textBubble = x
        
        textBubble.bubble.backgroundColor = .messageBackground
        textBubble.bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner ]
        textBubble.text.textColor = .fantasyBlack
        textBubble.date.textColor = .init(fromHex: 0xafb4c1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textBubble.message = message
        
        let rect = CGRect(x: MessageStyle.sideInset,
                          y: MessageStyle.upDownInset,
                          width: position.totalWidth,
                          height: position.bubbleSize.height)
        textBubble.frame = rect
    }
    
}
