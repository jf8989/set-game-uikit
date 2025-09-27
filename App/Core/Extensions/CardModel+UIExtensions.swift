// App/Core/Extensions/CardModel+UIExtensions.swift

import Foundation
import UIKit

// MARK: - CardColor / uiColor ext.
extension CardColor {

    var uiColor: UIColor {
        switch self {
        case .red:
            return .systemRed
        case .green:
            return .systemGreen
        case .purple:
            return .systemPurple
        }
    }
}

// MARK: - SetEvalStatus / uiColor ext.
extension SetEvalStatus {

    /// Color used for selection overlay when an evaluation is present.
    var uiColor: UIColor? {
        switch self {
        case .none: return nil
        case .found: return .systemGreen
        case .fail: return .systemRed
        }
    }
}

// MARK: - CardSymbol ext.
extension CardSymbol {

    func path(in rect: CGRect) -> UIBezierPath {
        switch self {
        case .diamond:
            return UIBezierPath.setDiamond(in: rect)
        case .oval:
            return UIBezierPath.setOval(in: rect)
        case .squiggle:
            return UIBezierPath.setSquiggle(in: rect, rotationDegrees: SetGameTheme.CardUI.squiggleRotationDegrees)
        }
    }
}

// MARK: - CardShading ext.
extension CardShading {

    /// Line width multiplier for the symbol stroke relative to base stroke.
    var strokeMultiplier: CGFloat {
        switch self {
        case .solid: return 1.0
        case .open: return 1.5
        case .striped: return 1.25
        }
    }

    /// Stripe spacing given a glyph height.
    func stripeSpacing(for glyphHeight: CGFloat) -> CGFloat {
        max(3.0, glyphHeight * SetGameTheme.CardUI.stripeSpacingPerGlyphHeight)
    }

    /// Preferred alpha for stripe color.
    var stripeAlpha: CGFloat { SetGameTheme.CardUI.stripeAlpha }
}

// MARK: - CardSet / Accessibility ext.
extension CardSet {

    var accessibilityLabelText: String {
        let numberText: String = {
            switch number {
            case .one: return "one"
            case .two: return "two"
            case .three: return "three"
            }
        }()

        let shadingText: String = {
            switch shading {
            case .solid: return "solid"
            case .open: return "open"
            case .striped: return "striped"
            }
        }()

        let colorText: String = {
            switch color {
            case .red: return "red"
            case .green: return "green"
            case .purple: return "purple"
            }
        }()

        let symbolText: String = {
            switch symbol {
            case .diamond: return "diamond"
            case .oval: return "oval"
            case .squiggle: return "squiggle"
            }
        }()

        return "\(numberText) \(shadingText) \(colorText) \(symbolText)"
    }
}
