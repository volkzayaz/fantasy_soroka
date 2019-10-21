//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import FMPhotoPicker

protocol ImagePicker {
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void)
}



class FMPhotoImagePicker: ImagePicker, FMPhotoPickerViewControllerDelegate {
    
    static let delegate = FMPhotoImagePicker()
    
    private var completion: ((UIImage) -> Void)? = nil
    
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void) {
        
        FMPhotoImagePicker.delegate.completion = completion
        
        var config = FMPhotoPickerConfig()
        config.selectMode = .single
        config.availableCrops = [FMCrop.ratioCustom]
        config.availableFilters = [FMFilter.None]
        
        let picker = FMPhotoPickerViewController(config: config)
        picker.delegate = FMPhotoImagePicker.delegate
        viewController.present(picker, animated: true)
        
    }
    
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        
        completion?(photos.first!)
        self.completion = nil
        picker.dismiss(animated: true, completion: {
            picker.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
}
