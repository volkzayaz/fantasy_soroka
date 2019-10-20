//
//  FantasyImagePicker.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

open class FantasyImagePicker: NSObject {

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
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]

        self.completion = completion

        super.init()

        self.pickerController.delegate = self
        self.owner = presentationController
    }

    public func present() {
        self.pickerController.modalPresentationStyle = .fullScreen
        owner?.present(self.pickerController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true) {
            self.completion(image!)
        }
    }
}

//MARK:- UIImagePickerControllerDelegate

extension FantasyImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

//MARK:- UINavigationControllerDelegate

extension FantasyImagePicker: UINavigationControllerDelegate {}
