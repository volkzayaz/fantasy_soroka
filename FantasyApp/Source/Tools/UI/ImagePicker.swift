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

        config.strings = [
            "picker_warning_over_image_select_format": "\(R.string.localizable.fantasyImagePickerLibraryPicker_warning_over_image_select_formatPart1()) %d \(R.string.localizable.generalImages())" ,
            "picker_warning_over_video_select_format": "\(R.string.localizable.fantasyImagePickerLibraryPicker_warning_over_video_select_formatPart1()) %d \(R.string.localizable.generalVideos())" ,

            "picker_button_cancel": R.string.localizable.generalCancel(),
            "picker_button_select_done": R.string.localizable.generalDone(),

            "present_button_back": R.string.localizable.generalBack(),
            "present_button_edit_image": R.string.localizable.generalEdit(),
            "editor_button_cancel": R.string.localizable.generalCancel(),
            "editor_button_done": R.string.localizable.generalDone(),
            "editor_menu_filter": R.string.localizable.fantasyImagePickerLibraryEditor_menu_filter(),
            "editor_menu_crop": R.string.localizable.fantasyImagePickerLibraryEditor_menu_crop(),
            "editor_menu_crop_button_reset": R.string.localizable.fantasyImagePickerLibraryEditor_menu_crop_button_reset(),
            "editor_menu_crop_button_rotate": R.string.localizable.fantasyImagePickerLibraryEditor_menu_crop_button_rotate(),
            "editor_crop_ratioCustom": R.string.localizable.fantasyImagePickerLibraryEditor_crop_ratioCustom(),
            "editor_crop_ratioOrigin": R.string.localizable.fantasyImagePickerLibraryEditor_crop_ratioOrigin(),
            "editor_crop_ratioSquare": R.string.localizable.fantasyImagePickerLibraryEditor_crop_ratioSquare(),
            "permission_dialog_title": R.string.localizable.fantasyImagePickerLibraryPermission_dialog_title(),
            "permission_dialog_message": R.string.localizable.fantasyImagePickerLibraryPermission_dialog_message(),
            "permission_button_ok": R.string.localizable.generalOk(),
            "permission_button_cancel": R.string.localizable.generalCancel(),
            "editor_crop_ratio4x3": "4:3",
            "editor_crop_ratio16x9": "16:9",
            "editor_crop_ratio9x16": "9x16",
            "present_title_photo_created_date_format":  "yyyy/M/d",
        ]

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
