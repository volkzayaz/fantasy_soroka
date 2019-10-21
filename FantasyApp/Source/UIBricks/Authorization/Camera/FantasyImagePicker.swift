//
//  FantasyImagePicker.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyImagePicker: NSObject {

    fileprivate let pickerController: UIImagePickerController
    private weak var owner: UIViewController?
    private var completion: ((UIImage) -> Void)

    static func galleryImagePicker(presentationController: UIViewController,  completion: @escaping (UIImage) -> Void) -> FantasyImagePicker {
        let p = FantasyImagePicker(presentationController: presentationController, completion: completion)
        p.pickerController.sourceType = .photoLibrary
        return p
    }

    public init(presentationController: UIViewController,  completion: @escaping (UIImage) -> Void) {

        self.pickerController = UIImagePickerController()
        self.completion = completion
        self.owner = presentationController
        super.init()
    }

    public func present() {
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.modalPresentationStyle = .fullScreen
        pickerController.delegate = self

        owner?.present(pickerController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true) {
            self.completion(image!)
        }
    }
}

//MARK:- UIImagePickerControllerDelegate

extension FantasyImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return pickerController(picker, didSelect: nil)
        }
        pickerController(picker, didSelect: image)
    }
}
