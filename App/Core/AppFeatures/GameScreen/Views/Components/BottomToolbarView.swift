// App/Core/AppFeatures/GameScreen/Views/Components/GameToolbarView.swift

import UIKit

final class BottomToolbarView: UIToolbar {
    let newGameButton = BorderedButton(title: "New Game")
    let shuffleButton = BorderedButton(title: "Shuffle")
    let dealButton = BorderedButton(title: "Deal 3")

    override init(frame: CGRect) {
        super.init(frame: frame)

        style = .translucent(blur: .systemMaterial)
        isTranslucent = false
        translatesAutoresizingMaskIntoConstraints = false

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems(
            [
                flex,
                UIBarButtonItem(customView: newGameButton),
                flex,
                UIBarButtonItem(customView: shuffleButton),
                flex,
                UIBarButtonItem(customView: dealButton),
                flex,
            ],
            animated: false
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
