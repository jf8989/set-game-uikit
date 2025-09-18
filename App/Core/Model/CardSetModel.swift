// App/Core/Model/SetCardModel.swift

import Foundation

// MARK: - Card Structure (the card and its attributes)
/// Identifiable + Equatable so SwiftUI diffing & .animation(value:) work.
struct CardSet: Identifiable, Equatable, Hashable {
    var id: UUID
    var color: CardColor
    var symbol: CardSymbol
    var shading: CardShading
    var number: CardNumber
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

// MARK: - Card Set Eval Status
enum SetEvalStatus {
    case none, found, fail
}
