// App/Core/AppFeatures/GameScreen/SetGameViewController.swift

import UIKit

final class SetGameViewController: UIViewController {

    // MARK: - Model
    private var game = SetGame()

    // Cache for layout recalculation: include size + capped count to fit
    private var lastLayoutKey: (visibleSize: CGSize, fitCount: Int) = (.zero, 0)

    private var lastAppliedContentInsets: UIEdgeInsets = .zero

    // MARK: - Feedback state + service
    private var lastShownEvaluation: SetEvalStatus = .none
    private let feedbackManager = FeedbackManager()

    // MARK: - Views
    private let headerView = HeaderView()
    private let toolbarView = GameToolbarView()

    private lazy var gridCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Theme.Layout.interitem
        flowLayout.minimumLineSpacing = Theme.Layout.lineSpacing
        flowLayout.sectionInset = UIEdgeInsets(
            top: Theme.Layout.lineSpacing,
            left: 0,
            bottom: Theme.Layout.lineSpacing,
            right: 0
        )
        flowLayout.sectionInsetReference = .fromContentInset

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardButtonCell.self, forCellWithReuseIdentifier: CardButtonCell.reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()

    // Grid adapter
    private let gridAdapter = SetGridAdapter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Game"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        setupGridAdapter()
        buildLayout()
        newGame()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateChromeInsetsIfNeeded()
        updateGridItemSize()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateChromeInsetsIfNeeded()
    }

    // MARK: - Layout
    private func buildLayout() {
        let recipe = SetGameLayoutBuilder(
            header: headerView,
            grid: gridCollectionView,
            toolbar: toolbarView
        )
        recipe.install(
            in: view,
            safe: view.safeAreaLayoutGuide,
            padding: Theme.Layout.outerPadding
        )
    }

    // MARK: - Grid Adapter setup / sync
    private func setupGridAdapter() {
        // Wire adapter
        gridCollectionView.dataSource = gridAdapter
        gridCollectionView.delegate = gridAdapter
        gridAdapter.onToggleCard = { [weak self] card in
            guard let self else { return }
            let previouslySelected = self.indexPathsForSelectedCards()
            self.game.choose(this: card)
            self.syncAdapterFromGame()
            self.updateSelectionUI(previouslySelected: previouslySelected)
        }

        // Wire buttons
        toolbarView.newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        toolbarView.shuffleButton.addTarget(self, action: #selector(shuffleCards), for: .touchUpInside)
        toolbarView.dealButton.addTarget(self, action: #selector(dealThree), for: .touchUpInside)
    }

    private func syncAdapterFromGame() {
        gridAdapter.cards = game.tableCards
        gridAdapter.selectedIds = Set(game.selectedCards.map(\.id))
        gridAdapter.evaluation = game.setEvalStatus
        toolbarView.dealButton.isEnabled = game.canDealMore
        headerView.scoreLabel.text = "Score: \(game.score)"
        headerView.cardsLeftLabel.text = "Deck: \(game.cardsLeft)"
    }

    // MARK: - Grid sizing (fit until freezeAt, then scroll)
    private func updateGridItemSize() {
        guard let flowLayout = gridCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        // Visible area = collection bounds minus adjusted insets (respects our run-under bars).
        let adjusted = gridCollectionView.adjustedContentInset
        let visibleWidth = gridCollectionView.bounds.width - adjusted.left - adjusted.right
        let visibleHeight = gridCollectionView.bounds.height - adjusted.top - adjusted.bottom
        guard visibleWidth > 0, visibleHeight > 0 else { return }

        // Smaller, “visible” size for sizing.
        let visibleSize = CGSize(width: visibleWidth, height: visibleHeight)

        // Fit until freezeAt, then allow scrolling.
        let actualCount = max(game.tableCards.count, 1)
        let fitCount = min(actualCount, Theme.Layout.stopResizingAfterItemCount)

        // Recompute only when either visible size or fitCount changes.
        let currentKey = (visibleSize: visibleSize, fitCount: fitCount)
        if currentKey == lastLayoutKey { return }

        let itemSize = GridLayoutHelper.itemSize(
            for: visibleSize,
            itemCount: actualCount,
            aspectRatio: Theme.Layout.cardAspectRatio,
            interitemSpacing: flowLayout.minimumInteritemSpacing,
            lineSpacing: flowLayout.minimumLineSpacing,
            freezeAtCount: Theme.Layout.stopResizingAfterItemCount
        )

        if flowLayout.itemSize != itemSize {
            flowLayout.itemSize = itemSize
            flowLayout.invalidateLayout()
        }
        lastLayoutKey = currentKey
    }

    // MARK: - Actions
    @objc private func newGame() {
        game.newGame()
        lastShownEvaluation = .none
        syncAdapterFromGame()
        updateUI()
    }

    @objc private func shuffleCards() {
        game.shuffleTableCards()
        feedbackManager.selectionChanged()
        syncAdapterFromGame()
        updateUI()
    }

    @objc private func dealThree() {
        game.dealCards()
        syncAdapterFromGame()
        updateUI()
    }

    // MARK: - Match / Mismatch Feedback
    private func indexPathsForSelectedCards() -> [IndexPath] {
        SelectionIndexHelper.indexPaths(for: game.selectedCards, in: game.tableCards)
    }

    // Closure helper (req #12): operate on each selected visible cell
    private func forEachSelectedCell(_ action: (CardButtonCell) -> Void) {
        for indexPath in indexPathsForSelectedCards() {
            if let cell = gridCollectionView.cellForItem(at: indexPath) as? CardButtonCell {
                action(cell)
            }
        }
    }

    private func showEvaluationFeedbackIfNeeded() {
        guard game.selectedCards.count == SetGame.GameRules.setSize else {
            lastShownEvaluation = .none
            return
        }
        let currentEvaluation = game.setEvalStatus
        guard currentEvaluation != .none, currentEvaluation != lastShownEvaluation else { return }

        feedbackManager.notify(evaluation: currentEvaluation)

        let flashUIColor: UIColor = (currentEvaluation == .found) ? .systemGreen : .systemRed
        forEachSelectedCell { cell in
            cell.flashFeedback(color: flashUIColor)
        }

        lastShownEvaluation = currentEvaluation
    }

    // MARK: - UI Updates
    private func updateUI() {  // full refresh
        view.layoutIfNeeded()
        updateGridItemSize()

        UIView.performWithoutAnimation {
            gridCollectionView.reloadData()
            gridCollectionView.layoutIfNeeded()
        }

        showEvaluationFeedbackIfNeeded()
    }

    // Update selection only
    private func updateSelectionUI(previouslySelected: [IndexPath]) {
        let nowSelected = indexPathsForSelectedCards()
        let changed = Array(Set(previouslySelected + nowSelected))

        guard !changed.isEmpty else { return }

        UIView.performWithoutAnimation {
            gridCollectionView.reloadItems(at: changed)
        }

        showEvaluationFeedbackIfNeeded()
    }

    private func updateChromeInsetsIfNeeded() {
        // Top: header bottom + a little breathing room
        let topInset = headerView.frame.maxY + Theme.Layout.outerPadding

        // Bottom: distance from toolbar top to bottom + breathing room
        let bottomDistance = view.bounds.height - toolbarView.frame.minY
        let bottomInset = bottomDistance + Theme.Layout.outerPadding

        let newInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        guard newInsets != lastAppliedContentInsets else { return }

        // Only snap to the top if the user is already pinned there (avoid jumps while scrolling)
        let wasPinnedToTop = abs(gridCollectionView.contentOffset.y + lastAppliedContentInsets.top) < 1.0

        gridCollectionView.contentInset = newInsets
        gridCollectionView.verticalScrollIndicatorInsets = newInsets
        lastAppliedContentInsets = newInsets

        if wasPinnedToTop {
            gridCollectionView.setContentOffset(CGPoint(x: 0, y: -newInsets.top), animated: false)
        }
    }
}
