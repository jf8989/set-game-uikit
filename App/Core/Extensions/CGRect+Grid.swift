// Path: App/Core/Extensions/CGRect+Grid.swift
// Role: Pure geometry. Computes pixel-aligned frames laid out in a grid that fits inside a rect.

import CoreGraphics

extension CGRect {
    /// Computes grid-aligned frames that fit `itemCount` items with a given `aspectRatio`.
    /// Frames are returned in row-major order (top-to-bottom, left-to-right) and pixel-aligned via `floor`.
    func gridFrames(
        count itemCount: Int,
        aspectRatio: CGFloat,
        interitem: CGFloat,
        lineSpacing: CGFloat
    ) -> [CGRect] {
        guard itemCount > 0, width > 0, height > 0 else { return [] }

        // 1) Choose number of columns that allows all rows to fit vertically.
        func columnsThatFit() -> Int {
            var testColumns = 1
            var requiredRows = itemCount
            repeat {
                let totalInteritem = CGFloat(max(0, testColumns - 1)) * interitem
                let candidateItemWidth = (width - totalInteritem) / CGFloat(testColumns)
                let candidateItemHeight = candidateItemWidth / aspectRatio

                let totalRowsHeight = CGFloat(requiredRows) * candidateItemHeight
                let totalLineSpacings = CGFloat(max(0, requiredRows - 1)) * lineSpacing
                let requiredHeight = totalRowsHeight + totalLineSpacings

                if requiredHeight <= height { return testColumns }
                testColumns += 1
                requiredRows = Int(ceil(Double(itemCount) / Double(testColumns)))
            } while testColumns <= itemCount
            return max(1, min(itemCount, testColumns))
        }

        let columns = columnsThatFit()
        let rows = Int(ceil(Double(itemCount) / Double(columns)))

        // 2) Compute pixel-aligned item size.
        let totalInteritem = CGFloat(max(0, columns - 1)) * interitem
        let rawItemWidth = (width - totalInteritem) / CGFloat(columns)
        let itemWidth = floor(rawItemWidth)
        let itemHeight = floor(itemWidth / aspectRatio)

        // 3) Build frames (row-major), left/top aligned inside self.
        var frames: [CGRect] = []
        frames.reserveCapacity(itemCount)

        var originY = minY
        for rowIndex in 0..<rows {
            var originX = minX
            let itemsInThisRow =
                (rowIndex == rows - 1)
                ? (itemCount - rowIndex * columns)
                : columns
            for _ in 0..<itemsInThisRow {
                let frame = CGRect(x: floor(originX), y: floor(originY), width: itemWidth, height: itemHeight)
                frames.append(frame)
                originX += itemWidth + interitem
            }
            originY += itemHeight + lineSpacing
        }

        return frames
    }
}
