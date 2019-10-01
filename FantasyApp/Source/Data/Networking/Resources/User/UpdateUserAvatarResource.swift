//
//  UpdateUserAvatarResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya

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
        
        let data = image.pngData()!.base64EncodedString()
        
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
        
        let data = image.pngData()!.base64EncodedString()
        
        let string = """
        { "image": "data:image/png;base64,\(data)"}
        """
        
        return .requestData(string.data(using: .utf8)!)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    typealias responseType = EmptyResponse
    
}
