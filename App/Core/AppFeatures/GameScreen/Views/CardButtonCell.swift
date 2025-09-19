// App/Core/AppFeatures/GameScreen/Views/CardButtonCell.swift

import UIKit

final class CardButtonCell: UICollectionViewCell {
    static let reuseID = "CardButtonCell"

    private let cardButton = UIButton(type: .system)
    private var lastConfiguredCard: CardSet?
    private var lastIsSelected: Bool = false
    private var lastEvaluation: SetEvalStatus = .none

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        cardButton.translatesAutoresizingMaskIntoConstraints = false
        cardButton.isUserInteractionEnabled = false  // collection view handles taps
        cardButton.titleLabel?.numberOfLines = 0
        cardButton.titleLabel?.textAlignment = .center
        cardButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cardButton.titleLabel?.minimumScaleFactor = 0.3

        contentView.addSubview(cardButton)
        NSLayoutConstraint.activate([
            cardButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cardButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardButton.setAttributedTitle(nil, for: .normal)
        contentView.layer.borderWidth = 0
        contentView.backgroundColor = .systemBackground
        lastConfiguredCard = nil
        lastIsSelected = false
        lastEvaluation = .none
    }

    // MARK: - Public API

    func configure(with card: CardSet, isSelected: Bool, evaluation: SetEvalStatus) {
        lastConfiguredCard = card
        lastIsSelected = isSelected
        lastEvaluation = evaluation

        contentView.backgroundColor = .systemBackground
        setSelectionBorder(isSelected: isSelected, evaluation: evaluation)

        // Build attributed title sized to fit the cell nicely.
        cardButton.setAttributedTitle(
            makeAttributedSymbols(for: card, in: contentView.bounds.size),
            for: .normal
        )
    }

    func setSelectionBorder(isSelected: Bool, evaluation: SetEvalStatus) {
        let borderUIColor: UIColor = {
            guard isSelected else { return UIColor.label }
            switch evaluation {
            case .found: return .systemGreen
            case .fail: return .systemRed
            case .none: return .systemBlue
            }
        }()
        contentView.layer.borderWidth = isSelected ? 3 : 2
        contentView.layer.borderColor = borderUIColor.cgColor
    }

    /// Brief visual flash to indicate match/mismatch across the selected trio.
    func flashFeedback(color: UIColor) {
        let originalBackground = contentView.backgroundColor
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.contentView.backgroundColor = color.withAlphaComponent(0.18)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.20) {
                    self.contentView.backgroundColor = originalBackground
                }
            }
        )
    }

    // MARK: - Dynamic text sizing

    /// Creates an attributed string for ▲ ● ■ with size derived from the cell.
    private func makeAttributedSymbols(for card: CardSet, in containerSize: CGSize) -> NSAttributedString {
        let symbolGlyph = glyph(for: card.symbol)
        let linesCount = card.number.rawValue

        // Layout constants
        let horizontalPadding: CGFloat = 8
        let verticalPadding: CGFloat = 8
        let lineSpacing: CGFloat = 6

        let usableWidth = max(0, containerSize.width - horizontalPadding * 2)
        let usableHeight = max(0, containerSize.height - verticalPadding * 2)

        // Target line height so that N lines + (N-1)*spacing fit vertically
        let totalSpacing = CGFloat(max(0, linesCount - 1)) * lineSpacing
        let maxLineHeightFromHeight = (usableHeight - totalSpacing) / CGFloat(linesCount)

        // Also cap by width to avoid overflow on narrow cells
        let maxLineHeightFromWidth = usableWidth * 0.65

        let targetLineHeight = max(12, min(maxLineHeightFromHeight, maxLineHeightFromWidth))
        let font = UIFont.systemFont(ofSize: targetLineHeight, weight: .semibold)

        // Paragraph style to center vertically-ish via line spacing
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = lineSpacing

        let uiColor = uiColor(for: card.color)
        let attributes: [NSAttributedString.Key: Any]
        switch card.shading {
        case .solid:
            attributes = [
                .font: font,
                .foregroundColor: uiColor,
                .strokeColor: uiColor,
                .strokeWidth: -3,
                .paragraphStyle: paragraph,
            ]
        case .open:
            attributes = [
                .font: font,
                .foregroundColor: UIColor.clear,
                .strokeColor: uiColor,
                .strokeWidth: 3,
                .paragraphStyle: paragraph,
            ]
        case .striped:
            attributes = [
                .font: font,
                .foregroundColor: uiColor.withAlphaComponent(0.30),
                .strokeColor: uiColor,
                .strokeWidth: -3,
                .paragraphStyle: paragraph,
            ]
        }

        let text = Array(repeating: symbolGlyph, count: linesCount).joined(separator: "\n")
        return NSAttributedString(string: text, attributes: attributes)
    }

    // MARK: - Mapping helpers

    private func glyph(for symbol: CardSymbol) -> String {
        // Assignment requires ▲ ● ■ — map your enums consistently.
        switch symbol {
        case .diamond: return "▲"
        case .oval: return "●"
        case .squiggle: return "■"
        }
    }

    private func uiColor(for color: CardColor) -> UIColor {
        switch color {
        case .red: return .systemRed
        case .green: return .systemGreen
        case .purple: return .systemPurple
        }
    }

    // If the cell resizes (rotation, split view), rebuild the text to maintain balance.
    override func layoutSubviews() {
        super.layoutSubviews()
        if let card = lastConfiguredCard {
            cardButton.setAttributedTitle(
                makeAttributedSymbols(for: card, in: contentView.bounds.size),
                for: .normal
            )
            setSelectionBorder(isSelected: lastIsSelected, evaluation: lastEvaluation)
        }
    }
}
