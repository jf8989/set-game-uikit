// App/Core/AppFeatures/GameScreen/Views/CardButtonCell.swift

import UIKit

final class CardButtonCell: UICollectionViewCell {
    static let reuseID = "CardButtonCell"

    private let cardButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        cardButton.translatesAutoresizingMaskIntoConstraints = false
        cardButton.isUserInteractionEnabled = false  // collection view handles taps
        contentView.addSubview(cardButton)

        NSLayoutConstraint.activate([
            cardButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Temporary appearance placeholder. We’ll set ▲ ● ■ with NSAttributedString next.
    func configurePlaceholderAppearance() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0
        cardButton.setAttributedTitle(nil, for: .normal)
    }

    func setSelectionBorder(isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 3 : 2
        contentView.layer.borderColor = (isSelected ? UIColor.systemBlue : UIColor.label).cgColor
    }

    // Prep for req #11: expose a way to set attributed title cleanly.
    func setAttributedTitle(_ attributedTitle: NSAttributedString?) {
        cardButton.setAttributedTitle(attributedTitle, for: .normal)
    }
}
