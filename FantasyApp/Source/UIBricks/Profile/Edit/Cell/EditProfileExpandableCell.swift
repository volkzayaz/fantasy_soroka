//
//  EditProfileExpandableCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import RxSwift

class EditProfileExpandableCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var stackTitleLabel: UILabel!
    @IBOutlet weak var expandableTextView: KMPlaceholderTextView!
    @IBOutlet weak var symbolsLeftLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var action: ((String?) -> Void)?
    
    weak var tableView: UITableView?
    
    var maximumAboutChars: Int {
        return 200
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let max = maximumAboutChars
        
        expandableTextView.rx.text
            .map { "\(max - ($0?.count ?? 0))" }
            .bind(to: symbolsLeftLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
    }
    
    func dropTitle() {
        stackTitleLabel.removeFromSuperview()
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
    
        let x = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        return x.count <= 100
        
    }

    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
            
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        action?(textView.text.count == 0 ? nil : textView.text)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if stackView.subviews.count == 2 {
            stackView.insertArrangedSubview(stackTitleLabel, at: 0)
        }
        
    }
    
}
