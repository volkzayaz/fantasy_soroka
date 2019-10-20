//
//  WelcomeViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class WelcomeViewController: UIViewController, MVVM_View {

    var viewModel: WelcomeViewModel!
}

// MAKR:- Actions

extension WelcomeViewController {

    @IBAction func register(_ sender: Any) {

//        let pickerController = FantasyImagePicker.galleryImagePicker(presentationController: self) { (image) in
////                     self.viewModel.photoChanged(photo: image)
//                 }
//
//                 pickerController.present()

        viewModel.presentRegister()
    }

    @IBAction func facebookSignIn(_ sender: Any) {
        viewModel.authorizeUsingFacebook()
    }

    @IBAction func presentSignIn() {
        viewModel.presentSignIn()
    }
}
