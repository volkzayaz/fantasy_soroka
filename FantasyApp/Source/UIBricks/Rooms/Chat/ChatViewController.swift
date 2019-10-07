//
//  ChatViewController.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class ChatViewController: BaseChatViewController, MVVM_View, BaseMessageInteractionHandlerProtocol {
    typealias ViewModelT = TextMessageViewModel<TextMessageModel<Chat.Message>>
    var viewModel: ChatViewModel!

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        configure()
    }

    deinit {
        viewModel.disconnect()
    }

    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputView(frame: .zero)
        chatInputView.translatesAutoresizingMaskIntoConstraints = false
        chatInputView.maxCharactersCount = 1000
        chatInputView.delegate = self
        return chatInputView
    }

    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        let textMessagePresenterBuilder = MessagePresenterBuilder(
            viewModelBuilder: TextMessageViewModelDefaultBuilder<TextMessageModel<Chat.Message>>(),
            interactionHandler: self
        )

        return [
            Chat.CellType.text.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.emoji.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.timeSeparator.rawValue: [TimeSeparatorPresenterBuilder()]
        ]
    }

    func userDidTapOnFailIcon(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>, failIconView: UIView) {}
    func userDidTapOnAvatar(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
    func userDidTapOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
    func userDidBeginLongPressOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
    func userDidEndLongPressOnBubble(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
    func userDidSelectMessage(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
    func userDidDeselectMessage(viewModel: TextMessageViewModel<TextMessageModel<Chat.Message>>) {}
}

private extension ChatViewController {
    func configure() {
        chatDataSource = viewModel
        chatDataSource?.delegate = self
        chatItemsDecorator = ChatItemsDecorator()

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
        return chatItems.map { DecoratedChatItem(chatItem: $0, decorationAttributes: attributes)}
    }
}