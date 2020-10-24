//
//  FantasyDeckTutorialView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 15.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyDeckTutorialView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle(R.string.localizable.fantasyDeckTutorialNext(), for: .normal)
        }
    }
    
    @IBOutlet weak var firstTextLabel: UILabel! {
        didSet {
            firstTextLabel.text = R.string.localizable.fantasyDeckTutorialFirstText()
        }
    }
    
    @IBOutlet weak var secondTextLabel: UILabel! {
        didSet {
            secondTextLabel.text = R.string.localizable.fantasyDeckTutorialSecondText()
        }
    }
    
    @IBOutlet weak var thirdTextLabel: UILabel! {
        didSet {
            thirdTextLabel.text = R.string.localizable.fantasyDeckTutorialThirdText()
        }
    }

    private var page: Int = 0

    var tutorialComplited: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    static var instance: FantasyDeckTutorialView {
          let v = UINib.init(nibName: "FantasyDeckTutorialView", bundle: nil).instantiate(withOwner: self, options: nil).first as! FantasyDeckTutorialView
          return v
      }

    private  func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 23.0
        clipsToBounds = true
    }
}

//MARK:- Actions

extension FantasyDeckTutorialView {

    @IBAction func next(_ sender: Any) {

        guard  page < 2 else {
            tutorialComplited?()
            return
        }

        let width :CGFloat = scrollView.bounds.width
        let horizontalOffset: CGFloat = width * CGFloat(page + 1)
        scrollView.setContentOffset(.init(x: horizontalOffset, y: 0), animated: true)
        page += 1

        pageControl.currentPage = page

        guard  page == 2 else { return }

        button.setTitle(R.string.localizable.fantasyDeckTutorialGotIt(), for: .normal)
    }
}
