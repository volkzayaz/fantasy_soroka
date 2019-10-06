//
//  Photo.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct Album: Codable, Equatable {
    
    ///this pair is an accessKey to resource
    let id: String
    let ownerId: String
    
    let isPrivate: Bool
    var images: [Photo]
    
    init(images: [Photo]) {
        self.id = "parseStubNotARealValue"
        self.ownerId = "parseStubNotARealValue"
        self.isPrivate = false
        
        self.images = images
    }
    
    ///Ideally, all albums fetched from server have ids
    ///though Parse knows nothing about Album entity
    ///To avoid numerous roundtrips to new backend
    ///we sometimes fake albums
    ///it's ok as long as we use it just as image storage
    ///as soon as we want to do any Album related API
    ///we can check this property to decide,
    ///whether we need to fetch real user Albums first
    var isReal: Bool { return id != "parseStubNotARealValue" }
        
}

struct StrippedAlbum: Codable, Equatable {
    
    let id: String
    let ownerId: String
    let isPrivate: Bool
    
}

struct Photo: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case url = "src"
        case thumbnailURL = "srcThumbnail"
    }
    
    let url: String
    let thumbnailURL: String
}

struct IsPrivatePhoto: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case url = "src"
        case thumbnailURL = "srcThumbnail"
        case isPrivate
    }
    
    let url: String
    let thumbnailURL: String
    let isPrivate: Bool
    
    var toRegular: Photo {
        return Photo(url: url, thumbnailURL: thumbnailURL)
    }
    
}
