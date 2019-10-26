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

class ChatViewController: BaseChatViewController, MVVM_View, BaseMessageInteractionHandlerProtocol {
    typealias ViewModelT = TextMessageViewModel<TextMessageModel<Room.Message>>
    var viewModel: ChatViewModel!

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.inputEnabled
            .drive(inputBarContainer.rx.isUserInteractionEnabled)
            .disposed(by: rx.disposeBag)
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

        let x = AcceptRejectBuilder()
        x.viewModel = viewModel
        
        return [
            Chat.CellType.text.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.emoji.rawValue: [textMessagePresenterBuilder],
            Chat.CellType.timeSeparator.rawValue: [TimeSeparatorPresenterBuilder()],
            Chat.CellType.acceptReject.rawValue: [x]
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
            //setupScreenCaptureProtection()
        //}
        chatDataSource = viewModel.chattoMess
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
        return chatItems
            //+ [AcceptRejectModel()])
            .map { DecoratedChatItem(chatItem: $0, decorationAttributes: attributes)}
    }
    
}
