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
    
    lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ChatViewModel.Row>>(configureCell: { [unowned self] (_, tv, ip, x) in
        
        switch x {
         
        case .message(let message):
            
            if message.isOwn {
                
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ownCell, for: ip)!
                cell.transform = tv.transform
            
                cell.position = self.viewModel.position(for: message)
                cell.message = message
                cell.textBubble.viewModel = self.viewModel
                
                return cell
            }
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.otherCell, for: ip)!
            cell.transform = tv.transform
            
            cell.position = self.viewModel.position(for: message)
            cell.message = message
            cell.avatar = self.viewModel.peerAvatar
            cell.textBubble.viewModel = self.viewModel
            
            return cell
            
        case .connection(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatHeaderCell, for: ip)!
            cell.transform = tv.transform
            
            cell.setConnections(x)
            cell.set(user: self.viewModel.initiator)
            cell.viewModel = self.viewModel
            
            return cell
            
        case .acceptReject:
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.acceptRejectCell, for: ip)!
            cell.transform = tv.transform
            
            cell.viewModel = self.viewModel
            
            return cell
         
        case .roomCreated:
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.roomCreatedCell, for: ip)!
            cell.transform = tv.transform
            
            let x = self.viewModel.slicePair
            
            cell.setParticipants(left: x.left, right: x.right)
            
            return cell
            
        }
        
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.register(R.nib.ownMessageCell)
        tv.register(R.nib.otherMessageCell)
        tv.register(R.nib.chatHeaderCell)
        tv.register(R.nib.acceptRejectCell)
        tv.register(R.nib.roomCreatedCell)
        
        tv.dataSource = nil
        tv.separatorStyle = .none
        tv.allowsSelection = false
        edgesForExtendedLayout = []
        
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

        switch model {
        case .message(let x):
            return viewModel.position(for: x).totalHeight
            
        case .connection(_):
            return 150
            
        case .acceptReject:
            return 121
            
        case .roomCreated:
            return 35
            
        }
        
    }
    
}
