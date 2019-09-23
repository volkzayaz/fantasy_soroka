//
//  Photo.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct Album: Decodable, Equatable {
    let id: String
    let isPrivate: Bool
    let images: [Photo]
}

struct Photo: Decodable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case url = "scr"
        case thumbnailURL = "srcThumbnail"
    }
    
    let url: String
    let thumbnailURL: String
    
}
