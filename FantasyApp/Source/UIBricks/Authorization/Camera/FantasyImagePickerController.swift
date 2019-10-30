//
//  FantasyImagePicker.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyImagePickerController: NSObject {

    private weak var owner: UIViewController?
    private var completion: ((UIImage) -> Void)

    static func galleryImagePicker(presentationController: UIViewController,  completion: @escaping (UIImage) -> Void) {
        let p = FantasyImagePickerController(presentationController: presentationController, completion: completion)
        p.present()
    }

    public init(presentationController: UIViewController,  completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        self.owner = presentationController
        super.init()
    }

    public func present() {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.modalPresentationStyle = .fullScreen
        pickerController.delegate = self

        owner?.present(pickerController, animated: true)
    }
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true) {
            guard let i = image else { return }
            self.completion(i)
        }
    }
}

//MARK:- UIImagePickerControllerDelegate

extension FantasyImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return pickerController(picker, didSelect: nil)
        }

        let fixedOrientationImage = image.fixedOrientation()

        pickerController(picker, didSelect: fixedOrientationImage)
    }
}

