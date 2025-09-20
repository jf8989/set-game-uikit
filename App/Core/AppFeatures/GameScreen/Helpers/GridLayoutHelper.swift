// App/Core/AppFeatures/GameScreen/Helpers/GridLayoutHelper.swift

import UIKit

enum GridLayoutHelper {

    static func itemSize(
        for containerSize: CGSize,
        itemCount: Int,
        aspectRatio: CGFloat,
        interitemSpacing: CGFloat,
        lineSpacing: CGFloat,
        freezeAtCount: Int
    ) -> CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }

        let boundedCount = max(1, min(itemCount, freezeAtCount))
        let numberOfColumns = columnsThatFit(
            itemCount: boundedCount,
            containerSize: containerSize,
            aspectRatio: aspectRatio,
            interitemSpacing: interitemSpacing,
            lineSpacing: lineSpacing
        )

        let totalInteritem = CGFloat(max(0, numberOfColumns - 1)) * interitemSpacing
        let itemWidth = floor((containerSize.width - totalInteritem) / CGFloat(numberOfColumns))
        let itemHeight = floor(itemWidth / aspectRatio)
        return CGSize(width: itemWidth, height: itemHeight)
    }

    private static func columnsThatFit(
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

        return max(1, min(itemCount, testColumns))
    }
}
