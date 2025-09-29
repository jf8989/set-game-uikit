// App/Core/AppFeatures/GameScreen/SetGameViewController.swift

import UIKit

final class SetGameViewController: UIViewController {

    // MARK: - Model
    private var game = SetGame()

    // MARK: - Feedback
    private let feedbackManager = FeedbackManager()
    private var lastShownEvaluation: SetEvalStatus = .none

    // MARK: - Views
    private let headerView = HeaderView()
    private let toolbarView = BottomToolbarView()
    private let cardBoardView = CardBoardView()

    // Rotation one-shot guard
    private var didTriggerShuffleThisGesture = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Game"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        buildLayout()
        wireButtons()
        wireGestures()
        newGame()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        relayoutBoard()
    }

    // MARK: - Layout (unchanged)
    private func buildLayout() {
        let recipe = SetGameLayoutBuilder(
            header: headerView,
            cardBoard: cardBoardView,
            toolbar: toolbarView
        )
        recipe.install(
            in: view,
            safe: view.safeAreaLayoutGuide,
            padding: SetGameTheme.Layout.outerPadding
        )
    }

    // MARK: - Wiring
    private func wireButtons() {
        toolbarView.newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        toolbarView.shuffleButton.addTarget(self, action: #selector(shuffleCards), for: .touchUpInside)
        toolbarView.dealButton.addTarget(self, action: #selector(dealThree), for: .touchUpInside)
    }

    private func wireGestures() {
        // Tap to select/deselect
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBoardTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        cardBoardView.addGestureRecognizer(tap)

        // Swipe down to deal
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipe.direction = .down
        swipe.delegate = self
        cardBoardView.addGestureRecognizer(swipe)

        // Two-finger rotation to shuffle
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        rotate.delegate = self
        cardBoardView.addGestureRecognizer(rotate)
    }

    // MARK: - Actions
    @objc private func newGame() {
        game.newGame()
        lastShownEvaluation = .none
        syncFromGame()
        updateUI()
    }

    @objc private func shuffleCards() {
        game.shuffleTableCards()
        feedbackManager.selectionChanged()
        syncFromGame()
        updateUI()
    }

    @objc private func dealThree() {
        game.dealCards()
        syncFromGame()
        updateUI()
    }

    // MARK: - UI Sync
    private func syncFromGame() {
        headerView.scoreLabel.text = "Score: \(game.score)"
        headerView.cardsLeftLabel.text = "Deck: \(game.cardsLeft)"
        toolbarView.dealButton.isEnabled = game.canDealMore

        cardBoardView.sync(to: game.tableCards)
        let selectedIds = Set(game.selectedCards.map(\.id))
        cardBoardView.applySelection(selectedIds: selectedIds)
    }

    private func updateUI() {
        relayoutBoard()
    }

    private func relayoutBoard() {
        let frames = cardBoardView.bounds.gridFrames(
            count: game.tableCards.count,
            aspectRatio: SetGameTheme.Layout.cardAspectRatio,
            interitem: SetGameTheme.Layout.interitem,
            lineSpacing: SetGameTheme.Layout.lineSpacing
        )
        cardBoardView.apply(frames: frames)
    }

    // MARK: - Match / Mismatch Feedback
    private func showEvaluationFeedbackIfNeeded() {
        guard game.selectedCards.count == SetGame.GameRules.setSize else {
            lastShownEvaluation = .none
            return
        }
        let currentEvalState = game.setEvalStatus
        guard currentEvalState != .none, currentEvalState != lastShownEvaluation else { return }

        // Haptics
        feedbackManager.notify(evaluation: currentEvalState)

        // Recolor the selected trio (green/red)
        let selectedIds = Set(game.selectedCards.map(\.id))
        cardBoardView.applySelection(selectedIds: selectedIds, evaluation: currentEvalState)

        lastShownEvaluation = currentEvalState
    }
}

extension SetGameViewController: UIGestureRecognizerDelegate {

    @objc func handleBoardTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: cardBoardView)
        guard let tapped = cardBoardView.hitTest(location, with: nil) as? CardView else { return }

        game.choose(this: tapped.card)
        feedbackManager.selectionChanged()
        syncFromGame()
        updateUI()
        showEvaluationFeedbackIfNeeded()
    }

    @objc func handleSwipeDown(_ recognizer: UISwipeGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        dealThree()
    }

    @objc func handleRotate(_ recognizer: UIRotationGestureRecognizer) {
        // Ensure two touches (rotation requires it, but be explicit)
        guard recognizer.numberOfTouches >= 2 else { return }

        let thresholdRadians: CGFloat = 0.2  // ~11.5°

        switch recognizer.state {
        case .began:
            didTriggerShuffleThisGesture = false

        case .changed:
            guard !didTriggerShuffleThisGesture,
                abs(recognizer.rotation) >= thresholdRadians
            else { return }

            didTriggerShuffleThisGesture = true
            shuffleCards()

        case .ended, .cancelled, .failed:
            didTriggerShuffleThisGesture = false

        default:
            break
        }
    }

    // Allows gestures to coexist where safe (tap + rotation can both recognize)
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
