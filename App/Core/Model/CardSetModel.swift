// App/Core/Model/SetCardModel.swift

import Foundation

// MARK: - Card Set Eval Status
enum SetEvalStatus {

    case none, found, fail
}

// MARK: - Card Attributes
enum CardColor: CaseIterable, Hashable {  // Has extension.

    case red, green, purple
}

enum CardSymbol: String, CaseIterable, Hashable {  // Has extension.

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

// MARK: - Card Structure/Attributes
struct CardSet: Identifiable, Equatable, Hashable {  // Has extension.

    var id: UUID
    var color: CardColor
    var symbol: CardSymbol
    var shading: CardShading
    var number: CardNumber
}
