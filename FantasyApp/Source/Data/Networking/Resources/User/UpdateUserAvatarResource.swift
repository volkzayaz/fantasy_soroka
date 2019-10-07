//
//  UpdateUserAvatarResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya
import Kingfisher

fileprivate let validationToken = "5b49f2cc-ebf8-46dd-ac1a-af43c200d949"

struct UpdateUserAvatarResource: AuthorizedAPIResource {
    
    typealias responseType = Avatar

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    enum CodingKeys: String, CodingKey {
        case imageData = "image"
    }
    
    var method: Moya.Method {
        return .put
    }
    
    var path: String {
        return "users/me/avatar"
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    var task: Task {
        
        let newImage =
        ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 400), mode: .aspectFill)
            .process(item: .image(image), options: [])!
        
        let data = newImage.pngData()!.base64EncodedString()
        
        let string = """
        { "image": "data:image/png;base64,\(data)"}
        """
        
        return .requestData(string.data(using: .utf8)!)
    }
 
    func encode(to encoder: Encoder) throws {
        
    }
    
}

struct ValidateProfileImage: APIResource {
    
    let image: UIImage
    
    var method: Moya.Method {
        return .put
    }
    
    var path: String {
        return "/images/validate-against-avatar-rules"
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    var task: Task {
        
        let newImage =
        ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 400), mode: .aspectFill)
            .process(item: .image(image), options: [])!
        
        let data = newImage.pngData()!.base64EncodedString()
        
        let string = """
        { "image": "data:image/png;base64,\(data)"}
        """
        
        return .requestData(string.data(using: .utf8)!)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    typealias responseType = EmptyResponse
    
    var headers: [String : String]? {
        return ["Authorization": "5b49f2cc-ebf8-46dd-ac1a-af43c200d949",
                "Content-Type": "application/json"]
    }
}

struct UploadAlbumImage: AuthorizedAPIResource {
    
    var task: Task {
        
        let newImage =
            ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 400), mode: .aspectFill)
                .process(item: .image(image), options: [])!
        
        let data = newImage.pngData()!.base64EncodedString()
        
        let string = """
        { "image": "data:image/png;base64,\(data)"}
        """
        
        return .requestData(string.data(using: .utf8)!)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    var path: String {
        return "/users/me/albums/\(album.id)"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    let image: UIImage
    let album: Album
    
    typealias responseType = Album
    
}

struct DeletePhoto: AuthorizedAPIResource {
    
    var task: Task {
        return .requestPlain
    }
    
    var path: String {
        return "/users/me/albums/\(fromAlbum.id)/\(photo.id)"
    }
    
    var method: Moya.Method {
        return .delete
    }
    
    let fromAlbum: Album
    let photo: Photo
    
    typealias responseType = EmptyResponse
    
}
