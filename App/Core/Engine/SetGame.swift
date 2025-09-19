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

    /// My function to reset the game to a fresh state.
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
        // If my user found a set, I'll replace those cards instead of adding 3 more.
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

    /// My core selection logic
    mutating func choose(this card: CardSet) {
        switch setEvalStatus {
        case .found:
            // User tapped while a matched set was showing.
            // Process that set and then decide what to do with the tap.
            let tappedWasInMatched = selectedCards.contains(where: { $0.id == card.id })
            drawAndReplaceMatchedCards()  // this also clears selectedCards and resets status

            // If the tapped card was part of the matched set, it's gone or replaced → no selection.
            // If it wasn't part of the matched set, start a new selection with the tapped card.
            if !tappedWasInMatched {
                if tableCards.contains(where: { $0.id == card.id }) {
                    selectedCards = [card]
                } else if let sameCardNow = tableCards.first(where: { $0 == card }) {
                    // fallback in case identity semantics change
                    selectedCards = [sameCardNow]
                }
            }

        case .fail:
            // User tapped after a failed match.
            // Clear the old selection and start a new one with the tapped card.
            selectedCards.removeAll()
            selectedCards.append(card)
            setEvalStatus = .none

        case .none:
            // This is the normal selection flow.
            if let index = selectedCards.firstIndex(where: { $0.id == card.id }) {
                // User tapped an already selected card, so I'll deselect it.
                selectedCards.remove(at: index)
            } else if selectedCards.count < 3 {
                // User tapped a new card, so I'll add it to the selection.
                selectedCards.append(card)
            }

            // Evaluate for a set only when my user has picked exactly 3 cards.
            if selectedCards.count == 3 {
                if selectedCards.isSet {
                    setEvalStatus = .found
                    score += 3
                } else {
                    setEvalStatus = .fail
                    score -= 1
                }
            }
        }
    }
}

// MARK: - Card Dealing Helpers

extension SetGame {
    /// My helper to deal the initial 12 cards at the start of the game.
    mutating func dealInitialCards() {
        tableCards.append(contentsOf: deck.prefix(12))
        deck.removeFirst(12)
    }

    /// My helper for a standard 3-card deal.
    private mutating func normalDraw() {
        let cardsToDeal = min(3, deck.count)
        if cardsToDeal > 0 {
            tableCards.append(contentsOf: deck.prefix(cardsToDeal))
            deck.removeFirst(cardsToDeal)
        }
    }

    /// My consolidated function to process a matched set.
    private mutating func drawAndReplaceMatchedCards() {
        let cardsToReplace = selectedCards

        // First, I'll move the matched cards to the discard pile for the View to see.
        discardPile.append(contentsOf: cardsToReplace)

        // If my deck still has cards, I'll replace the matched ones on the table.
        if !deck.isEmpty {
            let matchedIndices = cardsToReplace.compactMap { matchedCard in
                tableCards.firstIndex(where: { $0.id == matchedCard.id })
            }
            for index in matchedIndices {
                tableCards[index] = deck.removeFirst()
            }
        } else {
            // If my deck is empty, I'll just remove the matched cards.
            tableCards.removeAll { cardOnTable in
                cardsToReplace.contains(where: { $0.id == cardOnTable.id })
            }
        }

        // Finally, I'll reset the selection state.
        selectedCards.removeAll()
        setEvalStatus = .none
    }
}
