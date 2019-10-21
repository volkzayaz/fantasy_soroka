//
//  FantasyPhotoEditorViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class FantasyPhotoEditorViewController: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!

    var image: UIImage?

    private var completion: ((UIImage) -> Void)? = nil

    static func present(on viewController: UIViewController, image: UIImage, completion: @escaping (UIImage) -> Void) {

        let vc = R.storyboard.authorization.fantasyPhotoEditorViewController()!
        vc.completion = completion
        vc.image = image

        viewController.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let i = image else {
            return
        }

        previewImageView.image = i
    }
    
}

//MARK:- Actions

extension FantasyPhotoEditorViewController {

     @IBAction func retake(_ sender: Any) {
        navigationController?.popViewController(animated: true)
     }

    @IBAction func next(_ sender: Any) {

        guard let c = completion,
            let i = image else {
            print("No complition block!")
            return
        }

        navigationController?.popViewController(animated: true)

        c(i)
    }
    
}
