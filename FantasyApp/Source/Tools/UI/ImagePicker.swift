//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import YPImagePicker

protocol ImagePicker {
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void)
}

class FMPhotoImagePicker: ImagePicker {

    private var completion: ((UIImage) -> Void)? = nil
    
    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void) {

        UINavigationBar.appearance().tintColor = .fantasyPink

        var config = YPImagePickerConfiguration()

        var colors = config.colors
        colors.navigationBarActivityIndicatorColor = .fantasyPink
        colors.tintColor = .fantasyPink

        config.colors = colors
        config.library.mediaType = .photo
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.library.maxNumberOfItems = 1
        config.hidesStatusBar = true

        if #available(iOS 13.0, *) {
            config.preferredStatusBarStyle = .darkContent
        } else {
            // Fallback on earlier versions
            config.preferredStatusBarStyle = .default
        }

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in

            UINavigationBar.appearance().tintColor = .white

            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }

            let originalImage = items.singlePhoto?.originalImage
            let modifiedImage = items.singlePhoto?.modifiedImage

            completion(modifiedImage ?? originalImage!)
            picker.dismiss(animated: true, completion: nil)
        }

        viewController.present(picker, animated: true)
    }
    
}
