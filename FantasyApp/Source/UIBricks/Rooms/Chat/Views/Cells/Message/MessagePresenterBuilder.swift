//
//  MessagePresenter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 03.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

open class MessagePresenterBuilder<ViewModelBuilderT, InteractionHandlerT>: ChatItemPresenterBuilderProtocol where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: TextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {

    typealias ViewModelT = ViewModelBuilderT.ViewModelT
    typealias ModelT = ViewModelBuilderT.ModelT

    public init(viewModelBuilder: ViewModelBuilderT,
                interactionHandler: InteractionHandlerT?,
                menuPresenter: TextMessageMenuItemPresenterProtocol? = TextMessageMenuItemPresenter()) {
        self.viewModelBuilder = viewModelBuilder
        self.interactionHandler = interactionHandler
        self.menuPresenter = menuPresenter
    }

    private let viewModelBuilder: ViewModelBuilderT
    private let interactionHandler: InteractionHandlerT?
    private let menuPresenter: TextMessageMenuItemPresenterProtocol?
    private let layoutCache = NSCache<AnyObject, AnyObject>()

    private lazy var sizingCell: TextMessageCollectionViewCell = {
        return TextMessageCollectionViewCell.sizingCell()
    }()

    open func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return self.viewModelBuilder.canCreateViewModel(fromModel: chatItem)
    }

    open func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))

        let baseStyle = BaseMessageCollectionViewCellDefaultStyle(
            colors: .init(incoming: .messageBackground, outgoing: .myMessageBackground),
            dateTextStyle: .init(font: .regularFont(ofSize: 10), color: .basicGrey),
            avatarStyle: .init(size: CGSize(width: 30.0, height: 30.0), alignment: .bottom)
        )

        let cellStyle = TextMessageCollectionViewCellDefaultStyle(
            textStyle: .init(font: .regularFont(ofSize: 15),
                             incomingColor: .fantasyBlack,
                             outgoingColor: .title,
                             incomingInsets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16),
                             outgoingInsets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)),
            baseStyle: baseStyle
        )

        return TextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>(
            messageModel: chatItem as! ModelT,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            baseCellStyle: baseStyle,
            textCellStyle: cellStyle,
            layoutCache: layoutCache,
            menuPresenter: menuPresenter
        )
    }

    open var presenterType: ChatItemPresenterProtocol.Type {
        return TextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}
