//
//  RoomDetailsTitlePhotoView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 25.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

protocol RoomDetailsTitlePhotoViewDelegate: class {
    func didSelectedInitiator()
    func didSelectedPeer()
}

class RoomDetailsTitlePhotoView: UIView {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    weak var delegate: RoomDetailsTitlePhotoViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(initiatorTapped)))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(peerTapped)))
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        leftImageView.addEllipsMask()
    }
    
    func startAnimating() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.rightImageView.layer.add(rotation, forKey: "rotationAnimation")
    }

    func stopAnimating() {
         self.rightImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}

//MARK:- Actions

extension RoomDetailsTitlePhotoView {

    @objc func initiatorTapped() {
        guard let d = delegate else {
            return
        }

        d.didSelectedInitiator()
    }

    @objc func peerTapped() {
        guard let d = delegate else {
            return
        }

        if rightImageView.image == R.image.plus() {
            rightImageView.image = R.image.roomLoader()
            startAnimating()
        }
        
        d.didSelectedPeer()
    }
}
