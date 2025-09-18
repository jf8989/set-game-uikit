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
        !deck.isEmpty && tableCards.count < 24 || setEvalStatus == .found
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
            // My user tapped while a matched set was showing.
            // I'll process that set and this tap is now "consumed".
            drawAndReplaceMatchedCards()

        case .fail:
            // My user tapped after a failed match.
            // I'll clear the old selection and start a new one with the tapped card.
            selectedCards.removeAll()
            //            selectedCards.append(card)
            setEvalStatus = .none

        case .none:
            // This is my normal selection flow.
            if let index = selectedCards.firstIndex(where: { $0.id == card.id }) {
                // The user tapped an already selected card, so I'll deselect it.
                selectedCards.remove(at: index)
            } else if selectedCards.count < 3 {
                // The user tapped a new card, so I'll add it to the selection.
                selectedCards.append(card)
            }

            // I'll evaluate for a set only when my user has picked exactly 3 cards.
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
