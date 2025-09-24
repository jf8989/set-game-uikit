// App/Core/Extensions/CardModel+UIExtensions.swift

import Foundation
import UIKit // This is why these are separated from the "pure model".

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

// MARK: - CardSymbol / glyph ext.
extension CardSymbol {

    var glyph: String {
        switch self {
        case .diamond: return "▲"
        case .oval: return "●"
        case .squiggle: return "■"
        }
    }
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
