//
//  MultiSlider.swift
//  UISlider clone with multiple thumbs and values, and optional snap intervals.
//
//  Created by Yonat Sharon on 14.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import UIKit

@IBDesignable
open class MultiSlider: UIControl {
    @objc open var value: [CGFloat] = [] {
        didSet {
            if isSettingValue { return }
            adjustThumbCountToValueCount()
            adjustValuesToStepAndLimits()
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
            accessibilityValue = value.description
        }
    }

    @IBInspectable open dynamic var minimumValue: CGFloat = 0 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open dynamic var maximumValue: CGFloat = 1 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open dynamic var isContinuous: Bool = true

    /// snap thumbs to specific values, evenly spaced. (default = 0: allow any value)
    @IBInspectable open dynamic var snapStepSize: CGFloat = 0 { didSet { adjustValuesToStepAndLimits() } }

    /// generate haptic feedback when hitting snap steps
    @IBInspectable open dynamic var isHapticSnap: Bool = true

    @IBInspectable open dynamic var thumbCount: Int {
        get {
            return thumbViews.count
        }
        set {
            guard newValue > 0 else { return }
            updateValueCount(newValue)
            adjustThumbCountToValueCount()
        }
    }

    /// make specific thumbs fixed (and grayed)
    @objc open var disabledThumbIndices: Set<Int> = [] {
        didSet {
            for i in 0 ..< thumbCount {
                thumbViews[i].blur(disabledThumbIndices.contains(i))
            }
        }
    }

    /// show value labels next to thumbs. (default: show no label)
    @objc open dynamic var valueLabelPosition: NSLayoutConstraint.Attribute = .notAnAttribute {
        didSet {
            valueLabels.removeViewsStartingAt(0)
            if valueLabelPosition != .notAnAttribute {
                for i in 0 ..< thumbViews.count {
                    addValueLabel(i)
                }
            }
        }
    }

    /// value label shows difference from previous thumb value (true) or absolute value (false = default)
    @IBInspectable open dynamic var isValueLabelRelative: Bool = false {
        didSet {
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
        }
    }

    // MARK: - Appearance

    @objc open dynamic var orientation: NSLayoutConstraint.Axis = .vertical {
        didSet {
            setupOrientation()
            invalidateIntrinsicContentSize()
            repositionThumbViews()
        }
    }

    /// track color before first thumb and after last thumb. `nil` means to use the tintColor, like the rest of the track.
    @IBInspectable open dynamic var outerTrackColor: UIColor? {
        didSet {
            updateOuterTrackViews()
        }
    }

    @IBInspectable open dynamic var thumbImage: UIImage? {
        didSet {
            thumbViews.forEach { $0.image = thumbImage }
            setupTrackLayoutMargins()
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable public dynamic var showsThumbImageShadow: Bool = true {
        didSet {
            updateThumbViewShadowVisibility()
        }
    }

    @IBInspectable open dynamic var minimumImage: UIImage? {
        get {
            return minimumView.image
        }
        set {
            minimumView.image = newValue
            layoutTrackEdge(
                toView: minimumView,
                edge: .bottom(in: orientation),
                superviewEdge: orientation == .vertical ? .bottomMargin : .leadingMargin
            )
        }
    }

    @IBInspectable open dynamic var maximumImage: UIImage? {
        get {
            return maximumView.image
        }
        set {
            maximumView.image = newValue
            layoutTrackEdge(
                toView: maximumView,
                edge: .top(in: orientation),
                superviewEdge: orientation == .vertical ? .topMargin : .trailingMargin
            )
        }
    }

    @IBInspectable open dynamic var trackWidth: CGFloat = 2 {
        didSet {
            let widthAttribute: NSLayoutConstraint.Attribute = orientation == .vertical ? .width : .height
            trackView.removeFirstConstraint { $0.firstAttribute == widthAttribute }
            trackView.constrain(widthAttribute, to: trackWidth)
            updateTrackViewCornerRounding()
        }
    }

    @IBInspectable public dynamic var hasRoundTrackEnds: Bool = true {
        didSet {
            updateTrackViewCornerRounding()
        }
    }

    @IBInspectable public dynamic var keepsDistanceBetweenThumbs: Bool = true

    @objc open dynamic var valueLabelFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .halfEven
        return formatter
    }()

    // MARK: - Subviews

    @objc open var thumbViews: [UIImageView] = []
    @objc open var valueLabels: [UITextField] = [] // UILabels are a pain to layout, text fields look nice as-is.
    @objc open var trackView = UIView()
    @objc open var outerTrackViews: [UIView] = []
    @objc open var minimumView = UIImageView()
    @objc open var maximumView = UIImageView()

    // MARK: - Internals

    let slideView = UIView()
    let panGestureView = UIView()
    let margin: CGFloat = 32
    var isSettingValue = false
    var draggedThumbIndex: Int = -1
    lazy var defaultThumbImage: UIImage? = .circle()
    var selectionFeedbackGenerator = AvailableHapticFeedback()

    // MARK: - Overrides

    open override func tintColorDidChange() {
        let thumbTint = thumbViews.map { $0.tintColor } // different thumbs may have different tints
        super.tintColorDidChange()
        trackView.backgroundColor = actualTintColor
        for (thumbView, tint) in zip(thumbViews, thumbTint) {
            thumbView.tintColor = tint
        }
    }

    open override var intrinsicContentSize: CGSize {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: margin, height: margin)
        switch orientation {
        case .vertical:
            return CGSize(width: thumbSize.width + margin, height: UIView.noIntrinsicMetric)
        default:
            return CGSize(width: UIView.noIntrinsicMetric, height: thumbSize.height + margin)
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || alpha == 0 { return nil }
        if clipsToBounds { return super.hitTest(point, with: event) }
        return panGestureView.hitTest(panGestureView.convert(point, from: self), with: event)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // make visual editing easier
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor

        // evenly distribute thumbs
        let oldThumbCount = thumbCount
        thumbCount = 0
        thumbCount = oldThumbCount
    }
}

extension UIView {

    /// Sweeter: The color used to tint the view, as inherited from its superviews.
    public var actualTintColor: UIColor {
        var tintedView: UIView? = self
        while let currentView = tintedView, nil == currentView.tintColor {
            tintedView = currentView.superview
        }
        return tintedView?.tintColor ?? UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    }

    /// Sweeter: Set constant attribute. Example: `constrain(.width, to: 17)`
    @discardableResult public func constrain(
        _ at: NSLayoutConstraint.Attribute,
        to: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self, attribute: at, relatedBy: relation,
            toItem: nil, attribute: .notAnAttribute, multiplier: ratio, constant: to
        )
        constraint.priority = priority
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Pin subview at a specific place. Example: `constrain(label, at: .top)`
    @discardableResult public func constrain(
        _ subview: UIView,
        at: NSLayoutConstraint.Attribute,
        diff: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: subview, attribute: at, relatedBy: relation,
            toItem: self, attribute: at, multiplier: ratio, constant: diff
        )
        constraint.priority = priority
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Pin two subviews to each other. Example:
    ///
    /// `constrain(label, at: .leading, to: textField)`
    ///
    /// `constrain(textField, at: .top, to: label, at: .bottom, diff: 8)`
    @discardableResult public func constrain(
        _ subview: UIView,
        at: NSLayoutConstraint.Attribute,
        to subview2: UIView,
        at at2: NSLayoutConstraint.Attribute = .notAnAttribute,
        diff: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let at2real = at2 == .notAnAttribute ? at : at2
        let constraint = NSLayoutConstraint(
            item: subview, attribute: at, relatedBy: relation,
            toItem: subview2, attribute: at2real, multiplier: ratio, constant: diff
        )
        constraint.priority = priority
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Add subview pinned to specific places. Example: `addConstrainedSubview(button, constrain: .centerX, .centerY)`
    @discardableResult public func addConstrainedSubview(_ subview: UIView, constrain: NSLayoutConstraint.Attribute...) -> [NSLayoutConstraint] {
        return addConstrainedSubview(subview, constrainedAttributes: constrain)
    }

    @discardableResult func addConstrainedSubview(_ subview: UIView, constrainedAttributes: [NSLayoutConstraint.Attribute]) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        return constrainedAttributes.map { self.constrain(subview, at: $0) }
    }

    func addConstraintWithoutConflict(_ constraint: NSLayoutConstraint) {
        removeConstraints(constraints.filter {
            constraint.firstItem === $0.firstItem
                && constraint.secondItem === $0.secondItem
                && constraint.firstAttribute == $0.firstAttribute
                && constraint.secondAttribute == $0.secondAttribute
        })
        addConstraint(constraint)
    }

    /// Sweeter: Search the view hierarchy recursively for a subview that conforms to `predicate`
    public func viewInHierarchy(frontFirst: Bool = true, where predicate: (UIView) -> Bool) -> UIView? {
        if predicate(self) { return self }
        let views = frontFirst ? subviews.reversed() : subviews
        for subview in views {
            if let found = subview.viewInHierarchy(frontFirst: frontFirst, where: predicate) {
                return found
            }
        }
        return nil
    }

    /// Sweeter: Search the view hierarchy recursively for a subview with `aClass`
    public func viewWithClass<T>(_ aClass: T.Type, frontFirst: Bool = true) -> T? {
        return viewInHierarchy(frontFirst: frontFirst, where: { $0 is T }) as? T
    }
    
}

//
//  AvailableHapticFeedback.swift
//
//  Created by Yonat Sharon on 25.10.2018.
//

import UIKit

/// Wrapper for UIFeedbackGenerator that compiles on iOS 9
open class AvailableHapticFeedback {
    public enum Style: CaseIterable {
        case selection
        case impactLight, impactMedium, impactHeavy
        case notificationSuccess, notificationWarning, notificationError
    }

    public let style: Style

    public init(style: Style = .selection) {
        self.style = style
    }

    open func prepare() {
        if #available(iOS 10.0, *) {
            feedbackGenerator.prepare()
        }
    }

    open func generateFeedback() {
        if #available(iOS 10.0, *) {
            feedbackGenerator.generate(style: style)
        }
    }

    open func end() {
        _anyFeedbackGenerator = nil
    }

    @available(iOS 10.0, *)
    var feedbackGenerator: UIFeedbackGenerator & AvailableHapticFeedbackGenerator {
        if nil == _anyFeedbackGenerator {
            createFeedbackGenerator()
        }
        // swiftlint:disable force_cast force_unwrapping
        return _anyFeedbackGenerator! as! UIFeedbackGenerator & AvailableHapticFeedbackGenerator
        // swiftlint:enable force_cast force_unwrapping
    }

    private var _anyFeedbackGenerator: Any?

    @available(iOS 10.0, *)
    private func createFeedbackGenerator() {
        switch style {
        case .selection:
            _anyFeedbackGenerator = UISelectionFeedbackGenerator()
        case .impactLight:
            _anyFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        case .impactMedium:
            _anyFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        case .impactHeavy:
            _anyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        case .notificationSuccess, .notificationWarning, .notificationError:
            _anyFeedbackGenerator = UINotificationFeedbackGenerator()
        }
    }
}

protocol AvailableHapticFeedbackGenerator {
    func generate(style: AvailableHapticFeedback.Style)
}

@available(iOS 10.0, *)
extension UISelectionFeedbackGenerator: AvailableHapticFeedbackGenerator {
    func generate(style: AvailableHapticFeedback.Style) {
        selectionChanged()
    }
}

@available(iOS 10.0, *)
extension UIImpactFeedbackGenerator: AvailableHapticFeedbackGenerator {
    func generate(style: AvailableHapticFeedback.Style) {
        impactOccurred()
    }
}

@available(iOS 10.0, *)
extension UINotificationFeedbackGenerator: AvailableHapticFeedbackGenerator {
    func generate(style: AvailableHapticFeedback.Style) {
        let notificationFeedbackType: UINotificationFeedbackGenerator.FeedbackType
        switch style {
        case .notificationWarning:
            notificationFeedbackType = .warning
        case .notificationError:
            notificationFeedbackType = .error
        default:
            notificationFeedbackType = .success
        }
        notificationOccurred(notificationFeedbackType)
    }
}
