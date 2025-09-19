// App/Core/AppFeatures/GameScreen/SetGameViewController.swift

import UIKit

// MARK: - Layout constants
private enum Layout {
    static let outerPadding: CGFloat = 12
    static let interitem: CGFloat = 6
    static let lineSpacing: CGFloat = 6
}

// MARK: - Set Game Screen (Controller)
final class SetGameViewController: UIViewController {

    // MARK: Model
    private var game = SetGame()

    // MARK: Feedback State
    private var lastShownEvaluation: SetEvalStatus = .none

    // Reused haptics
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let notificationHaptic = UINotificationFeedbackGenerator()

    // MARK: UI
    private let scoreLabel = UILabel()
    private let cardsLeftLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        // Flow layout so we can resize items as the count grows (up to 30, then freeze size).
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumInteritemSpacing = Layout.interitem
        flowLayout.minimumLineSpacing = Layout.lineSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardButtonCell.self, forCellWithReuseIdentifier: CardButtonCell.reuseID)
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
        selectionHaptic.prepare()
        notificationHaptic.prepare()
        newGame()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGridItemSize()  // re-flow on rotation or when bounds change
    }

    // MARK: Actions
    @objc private func newGame() {
        game.newGame()
        lastShownEvaluation = .none
        updateUI()
    }

    @objc private func shuffleCards() {
        game.shuffleTableCards()
        selectionHaptic.selectionChanged()
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

        // Ensure the collection view has up-to-date bounds, then resize items.
        view.layoutIfNeeded()
        updateGridItemSize()

        // Reload without animations to avoid “blinking” cells.
        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }

        showEvaluationFeedbackIfNeeded()
    }

    // MARK: Match/Mismatch Feedback (#6)
    private func indexPathsForSelectedCards() -> [IndexPath] {
        let selectedIdentifiers = Set(game.selectedCards.map { $0.id })
        var selectedIndexPaths: [IndexPath] = []
        for (cardIndex, card) in game.tableCards.enumerated() {
            if selectedIdentifiers.contains(card.id) {
                selectedIndexPaths.append(IndexPath(item: cardIndex, section: 0))
            }
        }
        return selectedIndexPaths
    }

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

        notificationHaptic.notificationOccurred(currentEvaluation == .found ? .success : .error)

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

        // Add all three directly (no root stack)
        view.addSubview(headerRow)
        view.addSubview(collectionView)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            // Header at top
            headerRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.outerPadding),
            headerRow.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Layout.outerPadding
            ),
            headerRow.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Layout.outerPadding
            ),

            // Toolbar at bottom
            toolbar.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Layout.outerPadding
            ),
            toolbar.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Layout.outerPadding
            ),
            toolbar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.outerPadding
            ),

            // Collection view fills the middle
            collectionView.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: Layout.outerPadding),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Layout.outerPadding
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Layout.outerPadding
            ),
            collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -Layout.outerPadding),
        ])

        // Prefer giving height to the collection view
        collectionView.setContentHuggingPriority(.defaultLow, for: .vertical)
        collectionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    // MARK: Grid sizing to guarantee non-overlap up to 30 cards (then freeze size)
    private func updateGridItemSize() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let aspectRatio: CGFloat = 2.0 / 3.0
        let interitemSpacing = flowLayout.minimumInteritemSpacing
        let lineSpacing = flowLayout.minimumLineSpacing

        let contentSize = collectionView.bounds.size
        guard contentSize.width > 0, contentSize.height > 0 else { return }

        let actualCardCount = max(game.tableCards.count, 1)

        // Freeze item size once we hit 30 cards.
        let cardCountToFit = min(actualCardCount, 30)

        let numberOfColumns = columnsThatFit(
            itemCount: cardCountToFit,
            containerSize: contentSize,
            aspectRatio: aspectRatio,
            interitemSpacing: interitemSpacing,
            lineSpacing: lineSpacing
        )

        let totalInteritem = CGFloat(max(0, numberOfColumns - 1)) * interitemSpacing
        let itemWidth = floor((contentSize.width - totalInteritem) / CGFloat(numberOfColumns))
        let itemHeight = floor(itemWidth / aspectRatio)

        let newSize = CGSize(width: itemWidth, height: itemHeight)
        if flowLayout.itemSize != newSize {
            flowLayout.itemSize = newSize
            flowLayout.invalidateLayout()
        }
    }

    /// Finds a column count that lets all items fit vertically without overlap (scales down as needed).
    private func columnsThatFit(
        itemCount: Int,
        containerSize: CGSize,
        aspectRatio: CGFloat,
        interitemSpacing: CGFloat,
        lineSpacing: CGFloat
    ) -> Int {
        guard itemCount > 0 else { return 1 }

        var testColumns = 1
        var requiredRows = itemCount

        repeat {
            let totalInteritemSpacing = CGFloat(max(0, testColumns - 1)) * interitemSpacing
            let candidateItemWidth = (containerSize.width - totalInteritemSpacing) / CGFloat(testColumns)
            let candidateItemHeight = candidateItemWidth / aspectRatio
            let totalRowsHeight = CGFloat(requiredRows) * candidateItemHeight
            let totalRowSpacings = CGFloat(max(0, requiredRows - 1)) * lineSpacing
            let requiredHeight = totalRowsHeight + totalRowSpacings

            if requiredHeight <= containerSize.height {
                return testColumns
            }
            testColumns += 1
            requiredRows = Int(ceil(Double(itemCount) / Double(testColumns)))
        } while testColumns <= itemCount

        // Fall back to a sane value if nothing fit (should be rare).
        return max(1, min(itemCount, testColumns))
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
                withReuseIdentifier: CardButtonCell.reuseID,
                for: indexPath
            ) as! CardButtonCell

        let isCurrentlySelected = game.selectedCards.contains(card)
        let evaluationStatus = game.setEvalStatus  // .none / .found / .fail

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
