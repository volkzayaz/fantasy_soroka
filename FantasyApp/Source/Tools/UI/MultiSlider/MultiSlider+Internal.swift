//
//  MultiSlider+Internal.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 21/06/2019.
//

import UIKit

extension MultiSlider {
    func setup() {
        trackView.backgroundColor = actualTintColor
        updateTrackViewCornerRounding()
        slideView.layoutMargins = .zero
        setupOrientation()
        setupPanGesture()

        isAccessibilityElement = true
        accessibilityIdentifier = "multi_slider"
        accessibilityLabel = "slider"
        accessibilityTraits = [.adjustable]

        minimumView.isHidden = true
        maximumView.isHidden = true

        if #available(iOS 11.0, *) {
            valueLabelFormatter.addObserverForAllProperties(observer: self)
        }
    }

    private func setupPanGesture() {
        addConstrainedSubview(panGestureView)
        for edge: NSLayoutConstraint.Attribute in [.top, .bottom, .left, .right] {
            constrain(panGestureView, at: edge, diff: -edge.inwardSign * margin)
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        panGesture.delegate = self
        panGestureView.addGestureRecognizer(panGesture)
    }

    func setupOrientation() {
        trackView.removeFromSuperview()
        trackView.removeConstraints(trackView.constraints)
        slideView.removeFromSuperview()
        minimumView.removeFromSuperview()
        maximumView.removeFromSuperview()
        switch orientation {
        case .vertical:
            let centerAttribute: NSLayoutConstraint.Attribute
            if #available(iOS 12, *) {
                centerAttribute = .centerX // iOS 12 doesn't like .topMargin, .rightMargin
            } else {
                centerAttribute = .centerXWithinMargins
            }
            addConstrainedSubview(trackView, constrain: .top, .bottom, centerAttribute)
            trackView.constrain(.width, to: trackWidth)
            trackView.addConstrainedSubview(slideView, constrain: .left, .right)
            constrainVerticalTrackViewToLayoutMargins()
            addConstrainedSubview(minimumView, constrain: .bottomMargin, centerAttribute)
            addConstrainedSubview(maximumView, constrain: .topMargin, centerAttribute)
        default:
            let centerAttribute: NSLayoutConstraint.Attribute
            if #available(iOS 12, *) {
                centerAttribute = .centerY // iOS 12 doesn't like .leftMargin, .rightMargin
            } else {
                centerAttribute = .centerYWithinMargins
            }
            addConstrainedSubview(trackView, constrain: .left, .right, centerAttribute)
            trackView.constrain(.height, to: trackWidth)
            trackView.addConstrainedSubview(slideView, constrain: .top, .bottom)
            constrainHorizontalTrackViewToLayoutMargins()
            addConstrainedSubview(minimumView, constrain: .leftMargin, centerAttribute)
            addConstrainedSubview(maximumView, constrain: .rightMargin, centerAttribute)
        }
        setupTrackLayoutMargins()
    }

    func setupTrackLayoutMargins() {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: 2, height: 2)
        let thumbDiameter = orientation == .vertical ? thumbSize.height : thumbSize.width
        let halfThumb = thumbDiameter / 2 - 1 // 1 pixel for semi-transparent boundary
        if orientation == .vertical {
            trackView.layoutMargins = UIEdgeInsets(top: halfThumb, left: 0, bottom: halfThumb, right: 0)
            constrain(.width, to: max(thumbSize.width, trackWidth), relation: .greaterThanOrEqual)
        } else {
            trackView.layoutMargins = UIEdgeInsets(top: 0, left: halfThumb, bottom: 0, right: halfThumb)
            constrainHorizontalTrackViewToLayoutMargins()
            constrain(.height, to: max(thumbSize.height, trackWidth), relation: .greaterThanOrEqual)
        }
    }

    /// workaround to a problem in iOS 12-13, of constraining to `leftMargin` and `rightMargin`.
    func constrainHorizontalTrackViewToLayoutMargins() {
        trackView.constrain(slideView, at: .left, diff: trackView.layoutMargins.left)
        trackView.constrain(slideView, at: .right, diff: -trackView.layoutMargins.right)
    }

    /// workaround to a problem in iOS 12-13, of constraining to `topMargin` and `bottomMargin`.
    func constrainVerticalTrackViewToLayoutMargins() {
        trackView.constrain(slideView, at: .top, diff: trackView.layoutMargins.top)
        trackView.constrain(slideView, at: .bottom, diff: -trackView.layoutMargins.bottom)
    }

    func repositionThumbViews() {
        thumbViews.forEach { $0.removeFromSuperview() }
        thumbViews = []
        valueLabels.forEach { $0.removeFromSuperview() }
        valueLabels = []
        adjustThumbCountToValueCount()
    }

    func adjustThumbCountToValueCount() {
        if value.count == thumbViews.count {
            return
        } else if value.count < thumbViews.count {
            thumbViews.removeViewsStartingAt(value.count)
            valueLabels.removeViewsStartingAt(value.count)
        } else { // add thumbViews
            for _ in thumbViews.count ..< value.count {
                addThumbView()
            }
        }
        updateOuterTrackViews()
    }

    func updateOuterTrackViews() {
        outerTrackViews.removeViewsStartingAt(0)
        outerTrackViews.removeAll()
        guard nil != outerTrackColor else { return }
        guard let firstThumb = thumbViews.first, let lastThumb = thumbViews.last, firstThumb != lastThumb else { return }

        outerTrackViews = [
            outerTrackView(constraining: .top(in: orientation), to: firstThumb),
            outerTrackView(constraining: .bottom(in: orientation), to: lastThumb),
        ]
    }

    private func outerTrackView(constraining: NSLayoutConstraint.Attribute, to thumbView: UIView) -> UIView {
        let view = UIView()
        view.backgroundColor = outerTrackColor
        trackView.addConstrainedSubview(view, constrain: .top, .bottom, .left, .right)
        trackView.removeFirstConstraint { $0.firstItem === view && $0.firstAttribute == constraining }
        trackView.constrain(view, at: constraining, to: thumbView, at: .center(in: orientation))
        trackView.sendSubviewToBack(view)

        view.layer.cornerRadius = trackView.layer.cornerRadius
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = .direction(constraining.opposite)
        }

        return view
    }

    private func addThumbView() {
        let i = thumbViews.count
        let thumbView = UIImageView(image: thumbImage ?? defaultThumbImage)
        thumbView.addShadow()
        thumbViews.append(thumbView)
        slideView.addConstrainedSubview(thumbView, constrain: NSLayoutConstraint.Attribute.center(in: orientation).perpendicularCenter)
        positionThumbView(i)
        thumbView.blur(disabledThumbIndices.contains(i))
        addValueLabel(i)
        updateThumbViewShadowVisibility()
    }

    func updateThumbViewShadowVisibility() {
        thumbViews.forEach {
            $0.layer.shadowOpacity = showsThumbImageShadow ? 0.25 : 0
        }
    }

    func addValueLabel(_ i: Int) {
        guard valueLabelPosition != .notAnAttribute else { return }
        let valueLabel = UITextField()
        valueLabel.borderStyle = .none
        slideView.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let thumbView = thumbViews[i]
        slideView.constrain(valueLabel, at: valueLabelPosition.perpendicularCenter, to: thumbView)
        slideView.constrain(
            valueLabel, at: valueLabelPosition.opposite,
            to: thumbView, at: valueLabelPosition,
            diff: -valueLabelPosition.inwardSign * thumbView.diagonalSize / 4
        )
        valueLabels.append(valueLabel)
        updateValueLabel(i)
    }

    func updateValueLabel(_ i: Int) {
        let labelValue: CGFloat
        if isValueLabelRelative {
            labelValue = i > 0 ? value[i] - value[i - 1] : value[i] - minimumValue
        } else {
            labelValue = value[i]
        }
        valueLabels[i].text = valueLabelFormatter.string(from: NSNumber(value: Double(labelValue)))
    }

    func updateAllValueLabels() {
        for i in 0 ..< valueLabels.count {
            updateValueLabel(i)
        }
    }

    func updateValueCount(_ count: Int) {
        guard count != value.count else { return }
        isSettingValue = true
        if value.count < count {
            let appendCount = count - value.count
            var startValue = value.last ?? minimumValue
            let length = maximumValue - startValue
            let relativeStepSize = snapStepSize / (maximumValue - minimumValue)
            var step: CGFloat = 0
            if 0 == value.count && 1 < appendCount {
                step = (length / CGFloat(appendCount - 1)).truncated(relativeStepSize)
            } else {
                step = (length / CGFloat(appendCount)).truncated(relativeStepSize)
                if 0 < value.count {
                    startValue += step
                }
            }
            if 0 == step { step = relativeStepSize }
            value += stride(from: startValue, through: maximumValue, by: step)
        }
        if value.count > count { // don't add "else", since prev calc may add too many values in some cases
            value.removeLast(value.count - count)
        }

        isSettingValue = false
    }

    func adjustValuesToStepAndLimits() {
        var adjusted = value.sorted()
        for i in 0 ..< adjusted.count {
            let snapped = adjusted[i].rounded(snapStepSize)
            adjusted[i] = min(maximumValue, max(minimumValue, snapped))
        }

        isSettingValue = true
        value = adjusted
        isSettingValue = false

        for i in 0 ..< value.count {
            positionThumbView(i)
        }
    }

    func positionThumbView(_ i: Int) {
        let thumbView = thumbViews[i]
        let thumbValue = value[i]
        slideView.removeFirstConstraint { $0.firstItem === thumbView && $0.firstAttribute == .center(in: orientation) }
        let thumbRelativeDistanceToMax = (maximumValue - thumbValue) / (maximumValue - minimumValue)
        if orientation == .horizontal {
            if thumbRelativeDistanceToMax < 1 {
                slideView.constrain(thumbView, at: .centerX, to: slideView, at: .right, ratio: CGFloat(1 - thumbRelativeDistanceToMax))
            } else {
                slideView.constrain(thumbView, at: .centerX, to: slideView, at: .left)
            }
        } else { // vertical orientation
            if thumbRelativeDistanceToMax.isNormal {
                slideView.constrain(thumbView, at: .centerY, to: slideView, at: .bottom, ratio: CGFloat(thumbRelativeDistanceToMax))
            } else {
                slideView.constrain(thumbView, at: .centerY, to: slideView, at: .top)
            }
        }
        UIView.animate(withDuration: 0.1) {
            self.slideView.updateConstraintsIfNeeded()
        }
    }

    func layoutTrackEdge(toView: UIImageView, edge: NSLayoutConstraint.Attribute, superviewEdge: NSLayoutConstraint.Attribute) {
        removeFirstConstraint { $0.firstItem === self.trackView && ($0.firstAttribute == edge || $0.firstAttribute == superviewEdge) }
        if nil != toView.image {
            constrain(trackView, at: edge, to: toView, at: edge.opposite, diff: edge.inwardSign * 8)
        } else {
            constrain(trackView, at: edge, to: self, at: superviewEdge)
        }
    }

    func updateTrackViewCornerRounding() {
        trackView.layer.cornerRadius = hasRoundTrackEnds ? trackWidth / 2 : 1
        outerTrackViews.forEach { $0.layer.cornerRadius = trackView.layer.cornerRadius }
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
