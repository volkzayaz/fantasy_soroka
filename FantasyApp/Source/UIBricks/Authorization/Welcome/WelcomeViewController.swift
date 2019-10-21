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

//        FMPhotoImagePicker.present(on: self) { [unowned self] (image) in
//
//            FantasyPhotoEditorViewController.present(on: self, image: image) { [unowned self] (image) in
////                self.viewModel.photoChanged(photo: image)
//            }
//
//        }

        viewModel.presentRegister()
    }

    @IBAction func facebookSignIn(_ sender: Any) {
        viewModel.authorizeUsingFacebook()
    }

    @IBAction func presentSignIn() {
        viewModel.presentSignIn()
    }
}
