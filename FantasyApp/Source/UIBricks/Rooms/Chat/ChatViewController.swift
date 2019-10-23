//
//  ChatViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import ScreenShieldKit

class ChatViewController: BaseChatViewController, MVVM_View, BaseMessageInteractionHandlerProtocol {
    typealias ViewModelT = TextMessageViewModel<TextMessageModel<Room.Message>>
    var viewModel: ChatViewModel!

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        configure()
    }

    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputView(frame: .zero)
        chatInputView.translatesAutoresizingMaskIntoConstraints = false
        chatInputView.maxCharactersCount = 1000
        chatInputView.delegate = self
        return chatInputView
    }

    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        let textMessagePresenterBuilder = MessagePresenterBuilder<TextMessageViewModelDefaultBuilder<TextMessageModel<Room.Message>>, ChatViewController>(
            viewModelBuilder: TextMessageViewModelDefaultBuilder<TextMessageModel<Room.Message>>(),
            interactionHandler: nil /*passing self creates retain cycle*/
        )

        return [
            Chat.CellType.text.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.emoji.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.timeSeparator.rawValue: [TimeSeparatorPresenterBuilder()],
            Chat.CellType.acceptReject.rawValue: [AcceptRejectBuilder()]
        ]
    }

    func userDidTapOnFailIcon(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>, failIconView: UIView) {}
    func userDidTapOnAvatar(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
    func userDidTapOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
    func userDidBeginLongPressOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
    func userDidEndLongPressOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
    func userDidSelectMessage(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
    func userDidDeselectMessage(viewModel: TextMessageViewModel<TextMessageModel<Room.Message>>) {}
}

private extension ChatViewController {
    func configure() { 
        // TODO: uncomment this condition when ScreenShield testing is finished
        //if viewModel.room.settings?.isScreenShieldEnabled == true {
            setupScreenCaptureProtection()
        //}
        chatDataSource = viewModel
        chatDataSource?.delegate = self
        chatItemsDecorator = ChatItemsDecorator()
        collectionView?.backgroundColor = .white

        guard let superview = view.superview else {
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: superview.topAnchor),
            view.rightAnchor.constraint(equalTo: superview.rightAnchor),
            view.leftAnchor.constraint(equalTo: superview.leftAnchor),
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }

    func setupScreenCaptureProtection() {
        let containerView = SSKProtectedImageView(image: R.image.screenProtectionInactive())
        let imageView = UIImageView(image: R.image.screenProtectionActive())
        containerView.screenCaptureView.addSubview(imageView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = false
        view.insertSubview(containerView, belowSubview: collectionView!)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

extension ChatViewController: ChatInputViewDelegate {
    func inputViewSendButtonPressed(_ inputView: ChatInputView) {
        viewModel.sendMessage(text: inputView.inputText)
        inputView.inputText = ""
    }
}

class ChatItemsDecorator: ChatItemsDecoratorProtocol {
    
    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
        let attributes = ChatItemDecorationAttributes(
            bottomMargin: 8,
            messageDecorationAttributes: BaseMessageDecorationAttributes(
                canShowFailedIcon: false,
                isShowingTail: true,
                isShowingAvatar: true,
                isShowingSelectionIndicator: false,
                isSelected: false
            )
        )
        return chatItems
            //+ [AcceptRejectModel()])
            .map { DecoratedChatItem(chatItem: $0, decorationAttributes: attributes)}
    }
    
}



class MyCollectionViewCell: UICollectionViewCell {
    
    func doStuff() {
        
        contentView.backgroundColor = .red
        
    }
    
}

class AcceptRejectModel: NSObject, ChatItemProtocol {
    
    var type: ChatItemType {
        return Chat.CellType.acceptReject.rawValue
    }
    
    var uid: String { return "1" }
    
}

class AcceptRejectPresenter: ChatItemPresenterProtocol {
    
    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "MyCollectionViewCell")
    }
    
    var isItemUpdateSupported: Bool { return false }
    
    func update(with chatItem: ChatItemProtocol) {}
        
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 100
    }
    
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let daCell = cell as? MyCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }
        
        daCell.doStuff()
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
}

class AcceptRejectBuilder: ChatItemPresenterBuilderProtocol {
    
    func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem.type == Chat.CellType.acceptReject.rawValue
    }
    
    func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        return AcceptRejectPresenter()
    }
    
    var presenterType: ChatItemPresenterProtocol.Type {
        return AcceptRejectPresenter.self
    }
    
}
