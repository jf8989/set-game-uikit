// App/Core/AppFeatures/GameScreen/SetGameViewController.swift

import UIKit

// MARK: - Set Game Screen (Controller)
final class SetGameViewController: UIViewController {

    // MARK: Model
    private var game = SetGame()

    // MARK: Feedback state + service
    private var lastShownEvaluation: SetEvalStatus = .none
    private let feedbackService = FeedbackService()

    // MARK: UI
    private let scoreLabel = UILabel()
    private let cardsLeftLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumInteritemSpacing = Theme.Layout.interitem
        flowLayout.minimumLineSpacing = Theme.Layout.lineSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardButtonCell.self, forCellWithReuseIdentifier: CardButtonCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var newGameButton: UIButton = makeBorderedButton(title: "New Game", action: #selector(newGame))
    private lazy var shuffleButton: UIButton = makeBorderedButton(title: "Shuffle", action: #selector(shuffleCards))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGridItemSize()
    }

    // MARK: Actions
    @objc private func newGame() {
        game.newGame()
        lastShownEvaluation = .none
        updateUI()
    }

    @objc private func shuffleCards() {
        game.shuffleTableCards()
        feedbackService.selectionChanged()
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

        view.layoutIfNeeded()
        updateGridItemSize()

        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }

        showEvaluationFeedbackIfNeeded()
    }

    // MARK: Match/Mismatch Feedback (#6)
    private func indexPathsForSelectedCards() -> [IndexPath] {
        SelectionIndexHelper.indexPaths(for: game.selectedCards, in: game.tableCards)
    }

    // Closure helper (req #12): operate on each selected visible cell
    private func forEachSelectedCell(_ action: (CardButtonCell) -> Void) {
        for indexPath in indexPathsForSelectedCards() {
            if let cell = collectionView.cellForItem(at: indexPath) as? CardButtonCell {
                action(cell)
            }
        }
    }

    private func showEvaluationFeedbackIfNeeded() {
        guard game.selectedCards.count == 3 else {
            lastShownEvaluation = .none
            return
        }
        let currentEvaluation = game.setEvalStatus
        guard currentEvaluation != .none, currentEvaluation != lastShownEvaluation else { return }

        feedbackService.notify(evaluation: currentEvaluation)

        let flashUIColor: UIColor = (currentEvaluation == .found) ? .systemGreen : .systemRed
        forEachSelectedCell { cell in
            cell.flashFeedback(color: flashUIColor)
        }

        lastShownEvaluation = currentEvaluation
    }

    // MARK: Layout
    private func buildLayout() {
        // Header
        scoreLabel.font = .preferredFont(forTextStyle: .title3)
        cardsLeftLabel.font = .preferredFont(forTextStyle: .title3)

        let spacerView = UIView()
        let headerRow = UIStackView(arrangedSubviews: [scoreLabel, spacerView, cardsLeftLabel])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        // Toolbar (New • Shuffle • Deal 3)
        let toolbar = UIStackView(arrangedSubviews: [newGameButton, shuffleButton, dealButton])
        toolbar.axis = .horizontal
        toolbar.spacing = 12
        toolbar.distribution = .fillEqually
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerRow)
        view.addSubview(collectionView)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            // Header at top
            headerRow.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Theme.Layout.outerPadding
            ),
            headerRow.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Layout.outerPadding
            ),
            headerRow.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Layout.outerPadding
            ),

            // Toolbar at bottom
            toolbar.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Layout.outerPadding
            ),
            toolbar.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Layout.outerPadding
            ),
            toolbar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Theme.Layout.outerPadding
            ),

            // Collection view fills the middle
            collectionView.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: Theme.Layout.outerPadding),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Layout.outerPadding
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Layout.outerPadding
            ),
            collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -Theme.Layout.outerPadding),
        ])

        collectionView.setContentHuggingPriority(.defaultLow, for: .vertical)
        collectionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    // MARK: Grid sizing (fit until freezeAt, then scroll)
    private func updateGridItemSize() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let contentSize = collectionView.bounds.size
        guard contentSize.width > 0, contentSize.height > 0 else { return }

        let itemSize = GridLayoutHelper.itemSize(
            for: contentSize,
            itemCount: max(game.tableCards.count, 1),
            aspectRatio: Theme.Layout.cardAspectRatio,
            interitemSpacing: flowLayout.minimumInteritemSpacing,
            lineSpacing: flowLayout.minimumLineSpacing,
            freezeAtCount: Theme.Layout.freezeAtCount
        )

        if flowLayout.itemSize != itemSize {
            flowLayout.itemSize = itemSize
            flowLayout.invalidateLayout()
        }
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
}

// MARK: - DataSource + Delegate
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
                withReuseIdentifier: CardButtonCell.reuseIdentifier,
                for: indexPath
            ) as! CardButtonCell

        let isCurrentlySelected = game.selectedCards.contains(card)
        let evaluationStatus = game.setEvalStatus

        cell.configure(with: card, isSelected: isCurrentlySelected, evaluation: evaluationStatus)
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
