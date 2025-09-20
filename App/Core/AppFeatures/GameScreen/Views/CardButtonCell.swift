// App/Core/AppFeatures/GameScreen/Views/CardButtonCell.swift

import UIKit

// MARK: - CATransaction convenience
extension CATransaction {
    fileprivate static func withoutActions(_ body: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        body()
        CATransaction.commit()
    }
}

final class CardButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "CardButtonCell"

    private let cardButton = UIButton(type: .system)
    private var lastConfiguredCard: CardSet?
    private var lastIsSelected: Bool = false
    private var lastEvaluation: SetEvalStatus = .none

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Theme.CardUI.cornerRadius
        contentView.layer.masksToBounds = true

        cardButton.translatesAutoresizingMaskIntoConstraints = false
        cardButton.isUserInteractionEnabled = false
        cardButton.titleLabel?.numberOfLines = 0
        cardButton.titleLabel?.textAlignment = .center
        cardButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cardButton.titleLabel?.minimumScaleFactor = 0.3

        contentView.addSubview(cardButton)
        NSLayoutConstraint.activate([
            cardButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.CardUI.contentInset),
            cardButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Theme.CardUI.contentInset
            ),
            cardButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Theme.CardUI.contentInset
            ),
            cardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.CardUI.contentInset),
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

        // Background/color updates without implicit animations
        CATransaction.withoutActions {
            contentView.backgroundColor = .systemBackground
        }
        setSelectionBorder(isSelected: isSelected, evaluation: evaluation)

        // Accessibility
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = AccessibilityLabelFactory.make(for: card)

        // Avoid UILabel/title cross-fades
        UIView.performWithoutAnimation {
            cardButton.setAttributedTitle(
                AttributedSymbolFactory.make(for: card, in: contentView.bounds.size),
                for: .normal
            )
            cardButton.layoutIfNeeded()
        }
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

        CATransaction.withoutActions {
            contentView.layer.borderWidth = isSelected ? 3 : 2
            contentView.layer.borderColor = borderUIColor.cgColor
        }
    }

    // Brief visual flash to indicate match/mismatch across the selected trio.
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

    // Keep the reflow on rotation/resize, but don’t animate changes.
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let card = lastConfiguredCard else { return }

        UIView.performWithoutAnimation {
            cardButton.setAttributedTitle(
                AttributedSymbolFactory.make(for: card, in: contentView.bounds.size),
                for: .normal
            )
            cardButton.layoutIfNeeded()
        }
        setSelectionBorder(isSelected: lastIsSelected, evaluation: lastEvaluation)
    }
}
