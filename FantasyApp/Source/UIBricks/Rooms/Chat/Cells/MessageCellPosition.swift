//
//  MessageCellPosition.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum MessageStyle {
    
    static let font = UIFont.regularFont(ofSize: 15)
    
    static let sideInset: CGFloat = 16
    static let upDownInset: CGFloat = 8
    
    static let minWidth: CGFloat = 50
 
    static let avatarSize: CGFloat = 30
    static let avatarToBubleSpace: CGFloat = 8
    
}

struct MessageCellPosition {

    let totalHeight: CGFloat
    let totalWidth: CGFloat
    let bubbleSize: CGSize
    let textSize: CGSize
 
    init(message: Room.Message) {
        
        var textBound: CGRect
        if message.nonNullHackyText.isEmpty {
            textBound = .zero
        }
        else {
            
            textBound =
            message.nonNullHackyText.boundingRect(with: .init(width: cellWidth, height: CGFloat.greatestFiniteMagnitude),
                                      options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                      attributes: [.font: MessageStyle.font],
                                      context: nil)
            
            textBound.origin.x = message.isOwn ? textContainerSideMinorSpacing : textContainerSideMajorSpacing;
            textBound.origin.y = textContainerTop;
            
            textBound.size.width = max(textBound.size.width, MessageStyle.minWidth)
            
        }
        
        ///http://stackoverflow.com/questions/12084760/nsstring-boundingrectwithsize-slightly-underestimating-the-correct-height-why
        textSize = CGSize(width : ceil(textBound.size.width),
                          height: ceil(textBound.size.height))
        
        bubbleSize = CGSize(width: textSize.width + 32,
                            height: textSize.height + 6 + 12 + 12)
        
        var heigh: CGFloat = MessageStyle.upDownInset + //empty space
                             bubbleSize.height + //bubble
                             MessageStyle.upDownInset; ///bottom empty space
        
//        if (self.model.isMy || self.model.isGroupMessage) {
//            heigh += kSenderHeight + kSenderTextTop + kSenderTextBottom;
//        }
        
//        if (self.model.mediaItems.firstObject) {
//            heigh += kSenderTextTop;
//
//            for (GHMediaItem* m in self.model.mediaItems) {
//                heigh += kSenderTextBottom;
//                NSNumber* height = [_mediaHeightMap objectForKey:m];
//                if (!height) {
//                    height = @([MediaContainerView preferredHeightForMedia:m]);
//                    [_mediaHeightMap setObject:height forKey:m];
//                }
//                heigh += height.doubleValue;
//            }
//        }
        
        totalHeight = heigh;
        totalWidth = bubbleSize.width + MessageStyle.avatarSize + MessageStyle.avatarToBubleSpace
        
    }
    
    ///percantage of cell width
    
}

private var cellWidth: CGFloat {
    return UIScreen.main.bounds.size.width * 0.7
}

private var textContainerTop: CGFloat { return 10 }
private var textContainerSideMajorSpacing: CGFloat { return 15 }
private var textContainerSideMinorSpacing: CGFloat { return 10 }

private var senderTextTop: CGFloat { return 2 }
private var senderTextBottom: CGFloat { return 3 }
private var senderTextHeight: CGFloat { return 16 }
