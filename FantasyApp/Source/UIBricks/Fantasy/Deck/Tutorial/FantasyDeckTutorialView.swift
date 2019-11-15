//
//  FantasyDeckTutorialView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 15.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import MetalKit

class FantasyDeckTutorialView: UIView {

    @IBOutlet weak var mtkView: MTKView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var button: UIButton!

    private static func createSlides() -> [FantasyDeckTutorialSlide] {

        let slide1 = FantasyDeckTutorialSlide.instance
        slide1.image.image = UIImage(named: "fantasyTutorialSwipeLeft")
        slide1.label.text = "Swipe left to dislike a card"

        let slide2 = FantasyDeckTutorialSlide.instance
        slide2.image.image = UIImage(named: "fantasyTutorialSwipeRight")
        slide2.label.text = "Swipe right to like a card"

        let slide3 = FantasyDeckTutorialSlide.instance
        slide3.image.image = UIImage(named: "fantasyTutorialTap")
        slide3.label.text = "Tap the card to open it"

        return [slide1, slide2, slide3]
    }

    private let slides = FantasyDeckTutorialView.createSlides()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayout()
        configureStyling()
    }

    static var instance: FantasyDeckTutorialView {
          let v = UINib.init(nibName: "FantasyDeckTutorialView", bundle: nil).instantiate(withOwner: self, options: nil).first as! FantasyDeckTutorialView
          return v
      }

    override func layoutSubviews() {
        super.layoutSubviews()

        let b = bounds
        scrollView.frame = CGRect(x: 0, y: 0, width: b.width, height: b.height)
        scrollView.contentSize = CGSize(width: b.width * CGFloat(slides.count), height: b.height)
        scrollView.isPagingEnabled = true

        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: b.width * CGFloat(i), y: 0, width: b.width, height: b.height)
        }
    }
}

extension FantasyDeckTutorialView {

    func configureLayout() {
        backgroundColor = UIColor.green
        translatesAutoresizingMaskIntoConstraints = false

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0

        for i in 0 ..< slides.count {
            scrollView.addSubview(slides[i])
        }
    }

    func configureStyling() {
        layer.cornerRadius = 23.0
        clipsToBounds = true
    }
}
