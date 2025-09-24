// App/Core/AppFeatures/GameScreen/Views/Components/HeaderView.swift

import UIKit

final class HeaderView: UIToolbar {

    let scoreLabel = UILabel()
    let cardsLeftLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        applyToolbarAppearance(self, style: .translucent(blur: .systemMaterial))

        translatesAutoresizingMaskIntoConstraints = false
        isTranslucent = false

        // Configure labels
        scoreLabel.font = .preferredFont(forTextStyle: .title3)
        scoreLabel.adjustsFontForContentSizeCategory = true
        scoreLabel.numberOfLines = 1
        scoreLabel.textAlignment = .left
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = 0.85

        cardsLeftLabel.font = .preferredFont(forTextStyle: .title3)
        cardsLeftLabel.adjustsFontForContentSizeCategory = true
        cardsLeftLabel.numberOfLines = 1
        cardsLeftLabel.textAlignment = .right
        cardsLeftLabel.setContentHuggingPriority(.required, for: .horizontal)
        cardsLeftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardsLeftLabel.adjustsFontSizeToFitWidth = true
        cardsLeftLabel.minimumScaleFactor = 0.85

        // Items
        let left = UIBarButtonItem(customView: scoreLabel)
        let right = UIBarButtonItem(customView: cardsLeftLabel)
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems([left, flex, right], animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
