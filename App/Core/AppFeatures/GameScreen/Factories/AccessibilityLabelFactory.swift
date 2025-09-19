// App/Core/AppFeatures/GameScreen/Factories/AccessibilityLabelFactory.swift

import Foundation

enum AccessibilityLabelFactory {
    static func make(for card: CardSet) -> String {
        let numberText: String = {
            switch card.number {
            case .one: return "one"
            case .two: return "two"
            case .three: return "three"
            }
        }()

        let shadingText: String = {
            switch card.shading {
            case .solid: return "solid"
            case .open: return "open"
            case .striped: return "striped"
            }
        }()

        let colorText: String = {
            switch card.color {
            case .red: return "red"
            case .green: return "green"
            case .purple: return "purple"
            }
        }()

        let symbolText: String = {
            switch card.symbol {
            case .diamond: return "diamond"
            case .oval: return "oval"
            case .squiggle: return "squiggle"
            }
        }()

        return "\(numberText) \(shadingText) \(colorText) \(symbolText)"
    }
}
