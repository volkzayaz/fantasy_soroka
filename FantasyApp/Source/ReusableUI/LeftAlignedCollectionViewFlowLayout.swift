//
//  LeftAlignedCollectionViewFlowLayout.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 19.11.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributesArray = super.layoutAttributesForElements(in: rect) else { return nil }
        var newAttributesArray = [UICollectionViewLayoutAttributes]()
        
        for (index, attributes) in superAttributesArray.enumerated() {
            if index == 0 || superAttributesArray[index - 1].frame.origin.y != attributes.frame.origin.y {
                attributes.frame.origin.x = sectionInset.left
            } else {
                let previousAttributes = superAttributesArray[index - 1]
                let previousFrameRight = previousAttributes.frame.origin.x + previousAttributes.frame.width
                attributes.frame.origin.x = previousFrameRight + minimumInteritemSpacing
            }
            
            newAttributesArray.append(attributes)
        }
        
        return newAttributesArray
    }
}
