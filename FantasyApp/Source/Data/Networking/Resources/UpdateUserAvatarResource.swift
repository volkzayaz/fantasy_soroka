//
//  UpdateUserAvatarResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya

struct UpdateUserAvatarResource: AuthorizedAPIResource {
    var endpoint: APIEnpdoint {
        return .updateAvatar
    }

    typealias responseType = Avatar

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    enum CodingKeys: String, CodingKey {
        case imageData = "image"
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
