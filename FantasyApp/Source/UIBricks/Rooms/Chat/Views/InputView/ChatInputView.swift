//
//  ChatInputView.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 29.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import ChattoAdditions
import UIKit

public protocol ChatInputViewDelegate: class {
    func inputViewShouldBeginTextEditing(_ inputView: ChatInputView) -> Bool
    func inputViewDidBeginEditing(_ inputView: ChatInputView)
    func inputViewDidEndEditing(_ inputView: ChatInputView)
    func inputViewDidChangeText(_ inputView: ChatInputView)
    func inputViewSendButtonPressed(_ inputView: ChatInputView)
    func inputViewDidShowPlaceholder(_ inputView: ChatInputView)
    func inputViewDidHidePlaceholder(_ inputView: ChatInputView)
}

extension ChatInputViewDelegate {
    // optional functions
    func inputViewShouldBeginTextEditing(_ inputView: ChatInputView) -> Bool { return true }
    func inputViewDidBeginEditing(_ inputView: ChatInputView) {}
    func inputViewDidEndEditing(_ inputView: ChatInputView) {}
    func inputViewDidChangeText(_ inputView: ChatInputView) {}
    func inputViewDidShowPlaceholder(_ inputView: ChatInputView) {}
    func inputViewDidHidePlaceholder(_ inputView: ChatInputView) {}
}

public class ChatInputView: UIView {

    public var pasteActionInterceptor: PasteActionInterceptor? {
        get { return textView.pasteActionInterceptor }
        set { textView.pasteActionInterceptor = newValue }
    }

    public weak var delegate: ChatInputViewDelegate?

    public var shouldEnableSendButton = { (inputView: ChatInputView) -> Bool in
        return !inputView.textView.text.isEmpty
    }

    public var inputTextView: UITextView? {
        return textView
    }

    private var textViewContainer = UIView(frame: .zero)
    private var textView = ExpandableTextView(frame: .zero)
    private var sendButton = SecondaryButton(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    public var maxCharactersCount: UInt? // nil -> unlimited

    private func updateIntrinsicContentSizeAnimated() {
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: { () -> Void in
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }, completion: nil)
    }

    open override func layoutSubviews() {
        updateConstraints() // Interface rotation or size class changes will reset constraints as defined in interface builder -> constraintsForVisibleTextView will be activated
        super.layoutSubviews()
    }

    open func becomeFirstResponderWithInputView(_ inputView: UIView?) {
        textView.inputView = inputView

        if textView.isFirstResponder {
            textView.reloadInputViews()
        } else {
            textView.becomeFirstResponder()
        }
    }

    public var inputText: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            updateSendButton()
        }
    }

    public var inputSelectedRange: NSRange {
        get {
            return textView.selectedRange
        }
        set {
            textView.selectedRange = newValue
        }
    }

    public var placeholderText: String {
        get {
            return textView.placeholderText
        }
        set {
            textView.placeholderText = newValue
        }
    }

    fileprivate func updateSendButton() {
        sendButton.isEnabled = shouldEnableSendButton(self)
    }

    @objc private func buttonTapped() {
        delegate?.inputViewSendButtonPressed(self)
    }

    public override func updateConstraints() {
        super.updateConstraints()

        NSLayoutConstraint.activate([
            textViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            textViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            textViewContainer.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8),

            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),
            textView.leftAnchor.constraint(equalTo: textViewContainer.leftAnchor),
            textView.rightAnchor.constraint(equalTo: textViewContainer.rightAnchor),

            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
    }

    private func configure() {
        addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        addSubview(sendButton)

        textViewContainer.layer.cornerRadius = 18.0
        textViewContainer.clipsToBounds = true
        textViewContainer.backgroundColor = .messageBackground
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false

        textView.setContentCompressionResistancePriority(.required, for: .horizontal)
        textView.scrollsToTop = false
        textView.delegate = self
        textView.placeholderDelegate = self
        textView.textAlignment = .left
        textView.backgroundColor = .messageBackground
        textView.setTextPlaceholderFont(.regularFont(ofSize: 15))
        textView.setTextPlaceholderColor(.basicGrey)
        textView.placeholderText = R.string.localizable.chatInputViewPlaceholder()
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        textView.textColor = .fantasyBlack
        textView.font = .regularFont(ofSize: 15)
        textView.translatesAutoresizingMaskIntoConstraints = false

        sendButton.isEnabled = false
        sendButton.setImage(R.image.sendMessage(), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        updateConstraints()
    }
}

// MARK: UITextViewDelegate
extension ChatInputView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.inputViewShouldBeginTextEditing(self) ?? true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.inputViewDidEndEditing(self)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.inputViewDidBeginEditing(self)
    }

    public func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
        delegate?.inputViewDidChangeText(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn nsRange: NSRange, replacementText text: String) -> Bool {
        guard let maxCharactersCount = maxCharactersCount else { return true }
        let currentText: NSString = textView.text as NSString
        let currentCount = currentText.length
        let rangeLength = nsRange.length
        let nextCount = currentCount - rangeLength + (text as NSString).length
        return UInt(nextCount) <= maxCharactersCount
    }

}

// MARK: ExpandableTextViewPlaceholderDelegate
extension ChatInputView: ExpandableTextViewPlaceholderDelegate {
    public func expandableTextViewDidShowPlaceholder(_ textView: ExpandableTextView) {
        delegate?.inputViewDidShowPlaceholder(self)
    }

    public func expandableTextViewDidHidePlaceholder(_ textView: ExpandableTextView) {
        delegate?.inputViewDidHidePlaceholder(self)
    }
}
