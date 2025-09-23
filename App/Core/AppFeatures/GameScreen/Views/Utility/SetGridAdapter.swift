// App/Core/AppFeatures/GameScreen/Views/Utility/SetGridAdapter.swift

import UIKit

final class SetGridAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    // Inputs (VC sets these whenever state changes)
    var cards: [CardSet] = []
    var selectedIds: Set<UUID> = []
    var evaluation: SetEvalStatus = .none

    // Outputs
    var onToggleCard: ((CardSet) -> Void)?

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CardButtonCell.reuseIdentifier,
                for: indexPath
            ) as! CardButtonCell
        let card = cards[indexPath.item]
        cell.configure(
            with: card,
            isSelected: selectedIds.contains(card.id),
            evaluation: evaluation
        )
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onToggleCard?(cards[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        onToggleCard?(cards[indexPath.item])
    }
}
