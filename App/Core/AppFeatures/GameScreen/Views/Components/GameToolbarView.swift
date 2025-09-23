// App/Core/AppFeatures/GameScreen/Views/GameToolbarView.swift

import UIKit

final class GameToolbarView: UIView {
    let newGameButton = BorderedButton(title: "New Game")
    let shuffleButton = BorderedButton(title: "Shuffle")
    let dealButton = BorderedButton(title: "Deal 3")

    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        [newGameButton, shuffleButton, dealButton].forEach { stack.addArrangedSubview($0) }
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
