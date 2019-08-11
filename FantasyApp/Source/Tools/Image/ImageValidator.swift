//
//  ImageValidator.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum ImageValidationError: Error {
    case nudity
    case noFace
    case multipleFaces
}

enum ImageValidator {}
extension ImageValidator {
    
    static func validate(image: UIImage) throws {

        ///Everything's valid so far
        
        ///TODO: add nudity processing using CoreML
        
//        guard let personciImage = CIImage(image: photo) else {
//            return
//        }
//
//        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
//        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
//        let hasFace = faceDetector?.features(in: personciImage).count ?? 0 > 0
//
//        guard hasFace else {
//            print("no face")
//            return
//        }
        
        return
    }
    
}
