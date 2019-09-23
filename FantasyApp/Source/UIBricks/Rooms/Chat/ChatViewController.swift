//
//  ChatViewController.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MVVM_View {
    var viewModel: ChatViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        viewModel.messages.asDriver().drive(onNext: { [weak self] _ in
            self?.messagesCollectionView.reloadDataAndKeepOffset()
        }).disposed(by: rx.disposeBag)

        viewModel.isSendingMessage.asDriver().drive(onNext: { [weak self] isSendingMessage in
            if isSendingMessage {
                self?.messageInputBar.sendButton.startAnimating()
            } else {
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    deinit {
        viewModel.disconnect()
    }
}

private extension ChatViewController {
    func configure() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
//        scrollsToBottomOnKeyboardBeginsEditing = true
//        maintainPositionOnKeyboardFrameChanged = true
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return viewModel.currentSender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messages.value.count
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages.value[indexPath.section]
    }

//    func messageTopLabelAttributedText(for message: MessageType,
//                                       at indexPath: IndexPath) -> NSAttributedString? {
//
//    }

    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .myMessageBackground : .messageBackground
        }
    }

    func configureAvatarView(_ avatarView: AvatarView,
                             for message: MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) {
        // TODO: load user avatar here
    }

    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubbleTail(isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft,
                           .pointedEdge)
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        viewModel.sendMessage(text: text)

        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
