// App/Core/AppFeatures/GameScreen/SetGameViewController.swift

import UIKit

// MARK: - Set Game Screen (Controller)

final class SetGameViewController: UIViewController {

    // MARK: Model

    private var game = SetGame()

    // MARK: UI

    private let scoreLabel = UILabel()
    private let cardsLeftLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = Self.makeGridLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardButtonCell.self, forCellWithReuseIdentifier: CardButtonCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var newGameButton: UIButton = makeBorderedButton(title: "New Game", action: #selector(newGame))
    private lazy var dealButton: UIButton = makeBorderedButton(title: "Deal 3", action: #selector(dealThree))

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set"
        view.backgroundColor = .systemBackground
        buildLayout()
        newGame()
        updateUI()
    }

    // MARK: Actions

    @objc private func newGame() {
        game.newGame()
        updateUI()
    }

    @objc private func dealThree() {
        game.dealCards()  // replace if matched, else add 3
        updateUI()
    }

    // MARK: UI Updates

    private func updateUI() {
        scoreLabel.text = "Score: \(game.score)"
        cardsLeftLabel.text = "Deck: \(game.cardsLeft)"
        dealButton.isEnabled = game.canDealMore
        collectionView.reloadData()
    }

    // MARK: Layout

    private func buildLayout() {
        // Header row: Score — Spacer — Deck Left
        scoreLabel.font = .preferredFont(forTextStyle: .title3)
        cardsLeftLabel.font = .preferredFont(forTextStyle: .title3)

        let spacer = UIView()
        let headerRow = UIStackView(arrangedSubviews: [scoreLabel, spacer, cardsLeftLabel])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        // Bottom toolbar
        let toolbar = UIStackView(arrangedSubviews: [newGameButton, dealButton])
        toolbar.axis = .horizontal
        toolbar.spacing = 12
        toolbar.distribution = .fillEqually
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        // Root layout
        let rootStack = UIStackView(arrangedSubviews: [headerRow, collectionView, toolbar])
        rootStack.axis = .vertical
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }

    // MARK: Helpers

    private func makeBorderedButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.bordered()
        configuration.title = title
        button.configuration = configuration
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    /// Fixed 4-column grid (room for 24 = 4×6). Keeps ~2:3 aspect ratio per card.
    private static func makeGridLayout() -> UICollectionViewCompositionalLayout {
        let numberOfColumns = 4

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / CGFloat(numberOfColumns) * 1.5)  // 2:3 ratio
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: numberOfColumns
        )

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Ext: DataSource + Delegate

extension SetGameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        game.tableCards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let card = game.tableCards[indexPath.item]
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CardButtonCell.reuseID,
                for: indexPath
            ) as! CardButtonCell

        // Placeholder appearance until we switch to NSAttributedString (req #11).
        cell.configurePlaceholderAppearance()

        // Basic selection ring; full match/mismatch feedback comes next.
        let isCurrentlySelected = game.selectedCards.contains(card)
        cell.setSelectionBorder(isSelected: isCurrentlySelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedCard = game.tableCards[indexPath.item]
        game.choose(this: tappedCard)
        updateUI()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let tappedCard = game.tableCards[indexPath.item]
        game.choose(this: tappedCard)
        updateUI()
    }
}

#Preview {
    SetGameViewController()
}
