// Core/Engine/Factory/DeckFactory.swift

import Foundation

/// Creates an 81-card deck + shuffles it.
struct DeckFactory {
    static func createShuffledDeck() -> [CardSet] {
        CardColor.allCases.flatMap { color in
            CardSymbol.allCases.flatMap { symbol in
                CardNumber.allCases.flatMap { number in
                    CardShading.allCases.map { shading in
                        CardSet(
                            id: UUID(),
                            color: color,
                            symbol: symbol,
                            shading: shading,
                            number: number
                        )
                    }
                }
            }
        }
        .shuffled()
    }
}
