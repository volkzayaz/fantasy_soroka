//
//  ChatViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import SlackTextViewController

import RxDataSources

class ChatViewController: SLKTextViewController, MVVM_View {

    var viewModel: ChatViewModel!

    var tv: UITableView! {
        return tableView!
    }
    
    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Room.Message>>(configureCell: { [unowned self] (_, tv, ip, x) in
        
        if x.isOwn {
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ownCell, for: ip)!
            cell.transform = tv.transform
        
            cell.position = self.viewModel.position(for: x)
            cell.message = x
            
            return cell
        }
        
        let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.otherCell, for: ip)!
        cell.transform = tv.transform
        
        cell.position = self.viewModel.position(for: x)
        cell.message = x
        cell.avatar = self.viewModel.peerAvatar
        
        return cell
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.register(R.nib.ownMessageCell)
        tv.register(R.nib.otherMessageCell)
        tv.dataSource = nil
        tv.separatorStyle = .none
        
        textInputbar.rightButton.setImage(R.image.sendMessage()?.withRenderingMode(.alwaysOriginal),
                                          for: .normal)
        textInputbar.rightButton.setTitle("",
                                          for: .normal)
        
        textInputbar.textView.backgroundColor = .messageBackground
        textInputbar.textView.placeholder = R.string.localizable.chatInputViewPlaceholder()
        textInputbar.textView.placeholderColor = .basicGrey
        textInputbar.textView.placeholderFont = .regularFont(ofSize: 15)

        textInputbar.textView.textColor = .fantasyBlack
        textInputbar.textView.font = .regularFont(ofSize: 15)
        textInputbar.textView.layer.cornerRadius = 18
        textInputbar.textView.layer.borderWidth = 0
        
        textInputbar.barTintColor = .white
        textInputbar.clipsToBounds = true
        
        viewModel.inputEnabled
            .drive(textInputbar.rx.isUserInteractionEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.dataSource
            .drive(tv.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
    }

    override func didPressRightButton(_ sender: (Any)?) {
    
        let message = textView.text!
        
        viewModel.sendMessage(text: message)
        
        super.didPressRightButton(sender)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = dataSource[indexPath]
        
        return viewModel.position(for: model).totalHeight
    }
    
}



extension ChatViewController: ChatInputViewDelegate {
    func inputViewSendButtonPressed(_ inputView: ChatInputView) {
        viewModel.sendMessage(text: inputView.inputText)
        inputView.inputText = ""
    }
}

