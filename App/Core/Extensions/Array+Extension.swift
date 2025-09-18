// App/Core/Extensions/Array+Extension.swift

import Foundation

// MARK: - Set Evaluation Helpers

/// Evaluates if a card is a set
extension Array where Element == CardSet {
    var isSet: Bool {
        guard self.count == 3 else { return false }
        let colors = self.map { $0.color }
        let symbols = self.map { $0.symbol }
        let numbers = self.map { $0.number.rawValue }
        let shadings = self.map { $0.shading }

        return colors.allSameOrAllDifferent
            && symbols.allSameOrAllDifferent
            && numbers.allSameOrAllDifferent
            && shadings.allSameOrAllDifferent
    }
}

extension Array where Element: Hashable {
    var allSameOrAllDifferent: Bool {
        let unique = Set(self)
        return unique.count == 1 || unique.count == self.count
    }
}
