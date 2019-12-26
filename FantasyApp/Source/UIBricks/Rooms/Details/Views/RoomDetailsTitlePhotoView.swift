//
//  RoomDetailsTitlePhotoView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 25.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

protocol RoomDetailsTitlePhotoViewDelegate {
    func didSelectedInitiator()
    func didSelectedPeer()
}

class RoomDetailsTitlePhotoView: UIView {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    var delegate: RoomDetailsTitlePhotoViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(initiatorTapped)))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(peerTapped)))
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

        d.didSelectedPeer()
    }
}
