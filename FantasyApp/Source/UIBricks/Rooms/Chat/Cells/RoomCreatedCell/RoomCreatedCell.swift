//
//  RoomCreatedCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 24.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomCreatedCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    var viewModel: ChatViewModel! {
        didSet {
            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.slicePair.left.avatarURL)
                .map { $0 ?? R.image.noPhoto() }
                .drive(leftImageView.rx.image)
                .disposed(by: rx.disposeBag)

            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.slicePair.right.avatarURL)
                .map { $0 ?? R.image.noPhoto() }
                .drive(rightImageView.rx.image)
                .disposed(by: rx.disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(meTapped)))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(peerTapped)))
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        leftImageView.addEllipsMask()
    }
}

//MARK:- Actions

extension RoomCreatedCell {

    @objc func meTapped() {
        viewModel.presentMe()
    }

    @objc func peerTapped() {
        viewModel.presentPeer()
    }
}
