// Path: App/Core/AppFeatures/GameScreen/Views/CardBoardView.swift

import UIKit

final class CardBoardView: UIView {

    // Keep views by identity; order is maintained externally by caller.
    private var viewsById: [UUID: CardView] = [:]
    private(set) var orderedIds: [UUID] = []

    func sync(to cards: [CardSet]) {
        let newIds = cards.map(\.id)
        orderedIds = newIds

        // Remove stale
        let newIdSet = Set(newIds)
        for (identifier, view) in viewsById where !newIdSet.contains(identifier) {
            view.removeFromSuperview()
            viewsById.removeValue(forKey: identifier)
        }

        // Add/update
        for card in cards {
            if let existing = viewsById[card.id] {
                if existing.card != card { existing.card = card }
            } else {
                let view = CardView(card: card)
                addSubview(view)
                viewsById[card.id] = view
            }
        }
    }

    func apply(frames: [CGRect]) {
        guard frames.count == orderedIds.count else { return }
        UIView.performWithoutAnimation {
            for (index, identifier) in orderedIds.enumerated() {
                if let viewForCard = viewsById[identifier] {
                    viewForCard.frame = frames[index]
                }
            }
            layoutIfNeeded()
        }
    }

    func applySelection(selectedIds: Set<UUID>, evaluation: SetEvalStatus? = nil) {
        let color = evaluation?.uiColor ?? SetGameTheme.CardUI.selectionColor
        for (identifier, cardView) in viewsById {
            guard selectedIds.contains(identifier) else {
                cardView.isSelectionEmphasized = false
                cardView.selectionOverlayColor = nil
                continue
            }
            cardView.isSelectionEmphasized = true
            cardView.selectionOverlayColor = color
            cardView.setNeedsDisplay()
        }
    }

}
