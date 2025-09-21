// App/Core/Engine/SetGame.swift

import Foundation

/// Main rules for the Set card game.
struct SetGame {

    // MARK: - Properties
    var deck: [CardSet] = []
    var tableCards: [CardSet] = []
    var discardPile: [CardSet] = []
    var selectedCards: [CardSet] = []
    var setEvalStatus: SetEvalStatus = .none
    var score: Int = 0

    // UI helpers
    var cardsLeft: Int { deck.count }
    var canDealMore: Bool {
        setEvalStatus == .found || !deck.isEmpty
    }

    // MARK: - Initialization
    init() {
        generateDeck()
    }

    // MARK: - Game State
    mutating func newGame() {
        generateDeck()
    }

    /// Reset the game to a fresh state.
    mutating func generateDeck() {
        tableCards.removeAll()
        selectedCards.removeAll()
        discardPile.removeAll()
        setEvalStatus = .none
        score = 0
        deck = DeckFactory.createShuffledDeck()
        dealInitialCards()
    }

    mutating func dealCards() {
        // If a set was found, replace those cards; otherwise add 3.
        if setEvalStatus == .found {
            drawAndReplaceMatchedCards()
        } else {
            normalDraw()
        }
    }

    mutating func shuffleTableCards() {
        tableCards.shuffle()
    }

    // MARK: - Core Selection Logic
    mutating func choose(this card: CardSet) {
        switch setEvalStatus {
        case .found:
            // Process the matched trio first.
            let tappedWasInMatched = selectedCards.contains(where: { $0.id == card.id })
            drawAndReplaceMatchedCards()  // clears selection + resets status

            // If tapped wasn't part of the matched set and it's still on table, start a new selection with it.
            if !tappedWasInMatched, tableCards.contains(where: { $0.id == card.id }) {
                selectedCards = [card]
            }

        case .fail:
            // Clear failed selection; start with tapped.
            selectedCards.removeAll()
            selectedCards.append(card)
            setEvalStatus = .none

        case .none:
            // Normal selection flow.
            if let index = selectedCards.firstIndex(where: { $0.id == card.id }) {
                selectedCards.remove(at: index)  // deselect
            } else if selectedCards.count < 3 {
                selectedCards.append(card)  // select
            }

            // Evaluate when exactly 3 are selected.
            if selectedCards.count == GameRules.setSize {
                if selectedCards.isSet {
                    setEvalStatus = .found
                    score += Scoring.matchReward
                } else {
                    setEvalStatus = .fail
                    score -= Scoring.mismatchPenalty
                }
            }
        }
    }
}

// MARK: - Game Rules + Scording Ext.
extension SetGame {
    enum GameRules {
        static let setSize = 3
        static let initialDealCount = 12
        static let subsequentDealCount = 3
    }

    enum Scoring {
        static let matchReward = 3
        static let mismatchPenalty = 1
    }
}

// MARK: - Card Dealing Helpers Ext.
extension SetGame {
    /// Deal the initial 12 cards at the start of the game.
    mutating func dealInitialCards() {
        guard tableCards.isEmpty else { return }
        let count = min(GameRules.initialDealCount, deck.count)
        tableCards.append(contentsOf: deck.prefix(count))
        deck.removeFirst(count)
    }

    /// Standard 3-card deal.
    private mutating func normalDraw() {
        let cardsToDeal = min(GameRules.subsequentDealCount, deck.count)
        if cardsToDeal > 0 {
            tableCards.append(contentsOf: deck.prefix(cardsToDeal))
            deck.removeFirst(cardsToDeal)
        }
    }

    /// Process a matched set: move to discard and replace/remove from table.
    private mutating func drawAndReplaceMatchedCards() {
        let cardsToReplace = selectedCards

        // Move the matched cards to the discard pile.
        discardPile.append(contentsOf: cardsToReplace)

        if !deck.isEmpty {
            // Replace matched indices from the deck.
            let matchedIndices = cardsToReplace.compactMap { matchedCard in
                tableCards.firstIndex(where: { $0.id == matchedCard.id })
            }
            for index in matchedIndices {
                tableCards[index] = deck.removeFirst()
            }
        } else {
            // Deck empty: remove matched cards from the table.
            tableCards.removeAll { cardOnTable in
                cardsToReplace.contains(where: { $0.id == cardOnTable.id })
            }
        }

        // Reset selection state.
        selectedCards.removeAll()
        setEvalStatus = .none
    }
}
