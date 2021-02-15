//
//  Array+Grouping.swift
//
//  Created by Vlad Soroka
//  Copyright © 2021. All rights reserved.
//

import Foundation

extension Array {
    
    func group<T: Hashable>(by: (Element) -> T, maxGroupLength: Int? = nil ) -> Array<[Element]> {
        
        return Dictionary(grouping: enumerated(), by: { by($0.element) } )
            .values
            .sorted { $0.first!.offset < $1.first!.offset }
            .map { x in
                
                if let i = maxGroupLength {
                    return x.prefix(i).map { $0.element }
                }
                else {
                    return x.map { $0.element }
                }
                
            }
        
    }
    
}
