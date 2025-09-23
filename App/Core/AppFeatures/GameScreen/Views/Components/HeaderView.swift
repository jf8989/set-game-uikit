// App/Core/AppFeatures/GameScreen/Views/HeaderView.swift

import UIKit

final class HeaderView: UIView {
    let scoreLabel = UILabel()
    let cardsLeftLabel = UILabel()
    private let spacerView = UIView()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        scoreLabel.font = .preferredFont(forTextStyle: .title3)
        cardsLeftLabel.font = .preferredFont(forTextStyle: .title3)

        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        [scoreLabel, spacerView, cardsLeftLabel].forEach { stack.addArrangedSubview($0) }
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
