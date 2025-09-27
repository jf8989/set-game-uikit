// App/Core/AppFeatures/GameScreen/Views/Components/HeaderView.swift

import UIKit

final class HeaderView: UIToolbar {

    let scoreLabel = UILabel()
    let cardsLeftLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        applying(SetGameTheme.HeaderUI.toolbarStyle)

        translatesAutoresizingMaskIntoConstraints = false
        isTranslucent = false

        // Configure labels (shared tokens)
        let textStyle = SetGameTheme.HeaderUI.labelTextStyle
        let minScale = SetGameTheme.HeaderUI.labelMinScaleFactor
        let hugging = SetGameTheme.HeaderUI.labelHuggingPriority
        let compress = SetGameTheme.HeaderUI.labelCompressionPriority
        let lines = SetGameTheme.HeaderUI.labelNumberOfLines

        scoreLabel.font = .preferredFont(forTextStyle: textStyle)
        scoreLabel.adjustsFontForContentSizeCategory = true
        scoreLabel.numberOfLines = lines
        scoreLabel.textAlignment = .left
        scoreLabel.setContentHuggingPriority(hugging, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(compress, for: .horizontal)
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = minScale

        cardsLeftLabel.font = .preferredFont(forTextStyle: textStyle)
        cardsLeftLabel.adjustsFontForContentSizeCategory = true
        cardsLeftLabel.numberOfLines = lines
        cardsLeftLabel.textAlignment = .right
        cardsLeftLabel.setContentHuggingPriority(hugging, for: .horizontal)
        cardsLeftLabel.setContentCompressionResistancePriority(compress, for: .horizontal)
        cardsLeftLabel.adjustsFontSizeToFitWidth = true
        cardsLeftLabel.minimumScaleFactor = minScale

        // Items
        let left = UIBarButtonItem(customView: scoreLabel)
        let right = UIBarButtonItem(customView: cardsLeftLabel)
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems([left, flex, right], animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
