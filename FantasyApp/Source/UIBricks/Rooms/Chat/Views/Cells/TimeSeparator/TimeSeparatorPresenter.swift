//
//  TimeSeparatorPresenter.swift
//  FantasyApp
//
//  Created by Admin on 30.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import UIKit
import Chatto

public class TimeSeparatorPresenterBuilder: ChatItemPresenterBuilderProtocol {

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is TimeSeparatorModel
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(canHandleChatItem(chatItem))
        return TimeSeparatorPresenter(timeSeparatorModel: chatItem as! TimeSeparatorModel)
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return TimeSeparatorPresenter.self
    }
}

class TimeSeparatorPresenter: ChatItemPresenterProtocol {

    let timeSeparatorModel: TimeSeparatorModel
    init(timeSeparatorModel: TimeSeparatorModel) {
        self.timeSeparatorModel = timeSeparatorModel
    }

    private static let cellReuseIdentifier = TimeSeparatorCollectionViewCell.self.description()

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(TimeSeparatorCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    let isItemUpdateSupported = false

    func update(with chatItem: ChatItemProtocol) {}

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: TimeSeparatorPresenter.cellReuseIdentifier, for: indexPath)
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let timeSeparatorCell = cell as? TimeSeparatorCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }

        timeSeparatorCell.text = timeSeparatorModel.date
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 24
    }
}
