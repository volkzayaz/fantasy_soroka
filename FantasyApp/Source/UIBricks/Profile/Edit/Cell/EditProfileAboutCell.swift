//
//  EditProfileAboutCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import RxSwift

class EditProfileAboutCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var expandableTextView: KMPlaceholderTextView!
    @IBOutlet weak var symbolsLeftLabel: UILabel!
    
    var viewModel: EditProfileViewModel!
    weak var tableView: UITableView?
    
    var maximumAboutChars: Int {
        return 100
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let max = maximumAboutChars
        
        expandableTextView.rx.text
            .map { "\(max - ($0?.count ?? 0))" }
            .bind(to: symbolsLeftLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
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
        viewModel.changed(about: textView.text)
    }
    
}
