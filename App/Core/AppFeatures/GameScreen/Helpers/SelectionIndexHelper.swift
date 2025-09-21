// App/Core/AppFeatures/GameScreen/Helpers/SelectionIndexHelper.swift

import UIKit

enum SelectionIndexHelper {

    static func indexPaths(
        for selectedCards: [CardSet],
        in tableCards: [CardSet]
    ) -> [IndexPath] {
        let selectedIdentifiers = Set(selectedCards.map { $0.id })
        var indexPaths: [IndexPath] = []
        for (cardIndex, card) in tableCards.enumerated() {
            if selectedIdentifiers.contains(card.id) {
                indexPaths.append(IndexPath(item: cardIndex, section: 0))
            }
        }
        return indexPaths
    }
}
