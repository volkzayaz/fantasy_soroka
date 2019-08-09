//
//  TextField.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 29.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

// MARK: - Style
public struct TextFieldStyle {
    let backgroundColor: UIColor = .clear
    let separatorColor: UIColor = .primary
    let emptySeparatorColor: UIColor = .primaryDisabled
    let separatorWidth: CGFloat = 1.0
    let textColor: UIColor = .primary
    let tintColor: UIColor = .primary
    let emptyTextColor: UIColor = .primaryDisabled
    let font: UIFont = .regularFont(ofSize: 18)
    let clearButtonImage: UIImage? = R.image.textFieldClear()
    // TODO: update images for show/hide buttons when they are ready
    let showButtonImage: UIImage? = R.image.textFieldClear()
    let hideButtonImage: UIImage? = R.image.textFieldClear()
    let separatorTopSpacing: CGFloat = 14.0
    let clearButtonLeftSpacing: CGFloat = 10.0
    let errorViewTopSpacing: CGFloat = 10.0
    let placeholderColor: UIColor = .primaryDisabled
    let placeholderFont: UIFont = .regularFont(ofSize: 18)
}

public class TextField: UIView {
    public override var intrinsicContentSize: CGSize {
        return verticalStackView.intrinsicContentSize
    }

    public enum TextFieldMode {
        case normal
        case secure
    }

    // MARK: - Subviews
    private let horizontalStackView = UIStackView()
    private let verticalStackView = UIStackView()
    private let textField = UITextField()
    private let showTextButton = UIButton()
    private let clearButton = UIButton()
    private let separatorView = UIView()
    private let errorView = ErrorView()

    // MARK: - Public properties and functions
    public var style: TextFieldStyle = TextFieldStyle() {
        didSet {
            applyStyle()
        }
    }

    public var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }

    public var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    public var mode: TextFieldMode = .normal {
        didSet {
            textField.isSecureTextEntry = mode == .secure
            updateShowTextButton()
        }
    }

    public var keyboardType: UIKeyboardType {
        set {
            textField.keyboardType = newValue
        }
        get {
            return textField.keyboardType
        }
    }

    public var errorMessage: String? {
        didSet {
            errorView.text = errorMessage
            errorView.isHidden = errorMessage == nil
        }
    }

   public weak var delegate: UITextFieldDelegate? {
        set {
            textField.delegate = newValue
        }
        get {
            return textField.delegate
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    @discardableResult public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    @discardableResult public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}


private extension TextField {
    // MARK: - Configuration
    func configure() {
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)

        showTextButton.addTarget(self, action: #selector(showText), for: .touchUpInside)
        showTextButton.setContentHuggingPriority(.required, for: .horizontal)
        showTextButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        clearButton.setContentHuggingPriority(.required, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        errorView.text = errorMessage
        errorView.isHidden = errorMessage == nil

        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading

        horizontalStackView.axis = .horizontal

        updateClearButton()
        updateShowTextButton()
        updateSeparatorColor()
        updateTextColor()
        updatePlaceholder()
        configureLayout()
        applyStyle()
    }

    func applyStyle() {
        clearButton.setImage(style.clearButtonImage, for: .normal)
        showTextButton.setImage(style.clearButtonImage, for: .normal)
        backgroundColor = style.backgroundColor
        tintColor = style.tintColor
        separatorView.backgroundColor = style.separatorColor

        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: style.separatorWidth)
        ])

        verticalStackView.setCustomSpacing(style.separatorTopSpacing,
                                           after: horizontalStackView)
        verticalStackView.setCustomSpacing(style.errorViewTopSpacing,
                                           after: separatorView)
        horizontalStackView.setCustomSpacing(style.clearButtonLeftSpacing,
                                             after: showTextButton)
    }

    func configureLayout() {
        [horizontalStackView, verticalStackView, textField, showTextButton,
         clearButton, separatorView, errorView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        addSubview(verticalStackView)

        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(separatorView)
        verticalStackView.addArrangedSubview(errorView)

        horizontalStackView.addArrangedSubview(textField)
        horizontalStackView.addArrangedSubview(showTextButton)
        horizontalStackView.addArrangedSubview(clearButton)

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            horizontalStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            separatorView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor)
        ])
    }

    // MARK: - State-dependent UI updates
    func updateShowTextButton() {
        let image = textField.isSecureTextEntry ? style.showButtonImage : style.hideButtonImage
        showTextButton.isHidden = mode == .normal || (textField.text?.count ?? 0) == 0
        showTextButton.isUserInteractionEnabled = mode != .normal
        showTextButton.setImage(image, for: .normal)
    }

    func updatePlaceholder() {
        guard let placeholder = placeholder else {
            textField.attributedPlaceholder = nil
            return
        }
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: style.placeholderColor, .font: style.placeholderFont]
        )
    }

    func updateSeparatorColor() {
        separatorView.backgroundColor = (text?.count ?? 0) == 0 ? style.emptySeparatorColor : style.separatorColor
    }

    func updateTextColor() {
        textField.textColor = (text?.count ?? 0) == 0 ? style.emptyTextColor : style.textColor
    }

    func updateClearButton() {
        clearButton.isHidden = (text?.count ?? 0) == 0
    }

    // MARK: - Actions
    @objc func clear() {
        text = nil
        clearButton.isHidden = true
    }

    @objc func showText() {
        textField.toggleTextVisibility()
        updateShowTextButton()
    }

    @objc func textFieldDidChange() {
        updateClearButton()
        updateTextColor()
        updateSeparatorColor()
        updateShowTextButton()
    }

    @objc func textFieldDidEndEditing() {
        updateClearButton()
        updateTextColor()
        updateSeparatorColor()
        updateShowTextButton()
    }
}
