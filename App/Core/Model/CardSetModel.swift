// App/Core/Model/SetCardModel.swift

import Foundation

// MARK: - Card Set Eval Status
enum SetEvalStatus {
    case none, found, fail
}

// MARK: - Card Attributes
enum CardColor: CaseIterable, Hashable {
    case red, green, purple
}

enum CardSymbol: String, CaseIterable, Hashable {
    case diamond
    case oval
    case squiggle
}

enum CardShading: CaseIterable, Hashable {
    case solid, open, striped
}

enum CardNumber: Int, CaseIterable, Hashable {
    case one = 1
    case two = 2
    case three = 3
}

// MARK: - Card Structure (the card and its attributes)
/// Identifiable + Equatable so SwiftUI diffing & .animation(value:) work.
struct CardSet: Identifiable, Equatable, Hashable {
    var id: UUID
    var color: CardColor
    var symbol: CardSymbol
    var shading: CardShading
    var number: CardNumber
}

// MARK: - Card Set Accessibility Ext.
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
