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

    @IBOutlet var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewWidth: NSLayoutConstraint!
    @IBOutlet var imageViewHeight: NSLayoutConstraint!

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

        guard let i = image else { return }

        imageView.image = i
        imageViewWidth.constant = i.size.width
        imageViewHeight.constant = i.size.height
        
        let scaleHeight = scrollView.frame.size.width/i.size.width
        let scaleWidth = scrollView.frame.size.height/i.size.height
        scrollView.minimumZoomScale = max(scaleWidth, scaleHeight)
        scrollView.zoomScale = max(scaleWidth, scaleHeight)
    }

    func crop() -> UIImage {
        let scale:CGFloat = 1/scrollView.zoomScale
        let x:CGFloat = scrollView.contentOffset.x * scale
        let y:CGFloat = scrollView.contentOffset.y * scale
        let width:CGFloat = scrollView.frame.size.width * scale
        let height:CGFloat = scrollView.frame.size.height * scale
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        return croppedImage
    }
}

//MARK:- UIScrollViewDelegate


extension FantasyPhotoEditorViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

//MARK:- Actions

extension FantasyPhotoEditorViewController {

    @IBAction func retake(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func next(_ sender: Any) {
        guard let c = completion else {
            print("No complition block!")
            return
        }

        navigationController?.popViewController(animated: false)
        c(crop())
    }
    
}
