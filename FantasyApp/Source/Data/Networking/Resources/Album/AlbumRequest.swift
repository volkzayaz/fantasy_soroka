//
//  AlbumRequest.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct GetAlbums: AuthorizedAPIResource {
    
    var path: String {
        switch of {
        case .me: return "/users/me/albums"
        case .user(let u): return "/users/\(u.id)/albums"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
        
    typealias responseType = [StrippedAlbum]
    
    var task: Task {
        
        switch of {
        case .me:
            return .requestParameters(parameters: ["v": "20191001"], encoding: URLEncoding.default)
            
        case .user(_):
            return .requestPlain
            
        }
        
    }
 
    enum Of {
        case user(User)
        case me
    }
    
    let of: Of
    
}

struct GetAlbumContent: AuthorizedAPIResource {
    
    var path: String {
        return "/users/\(album.ownerId)/albums/\(album.id)"
    }
    
    var method: Moya.Method {
        return .get
    }
        
    typealias responseType = Album
    
    var task: Task {
        return .requestPlain
    }
    
    let album: StrippedAlbum
    
}

struct GetImages: AuthorizedAPIResource {

    var path: String {
        switch of {
        case .me: return "/users/me/images"
        case .user(let u): return "/users/\(u.id)/images"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    typealias responseType = [IsPrivatePhoto]
    
    var task: Task {
        return .requestPlain
    }
    
    enum Of {
        case user(UserIdentifier)
        case me
    }
    
    let of: Of
    
}
