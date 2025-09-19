// App/Core/AppFeatures/GameScreen/Factory/AttributedSymbolFactory.swift

import UIKit

enum AttributedSymbolFactory {

    static func make(for card: CardSet, in containerSize: CGSize) -> NSAttributedString {
        let symbolGlyph = glyph(for: card.symbol)
        let linesCount = card.number.rawValue

        // Layout constants
        let horizontalPadding = Theme.CardUI.contentInset
        let verticalPadding = Theme.CardUI.contentInset
        let lineSpacing = Theme.CardUI.lineSpacing

        let usableWidth = max(0, containerSize.width - horizontalPadding * 2)
        let usableHeight = max(0, containerSize.height - verticalPadding * 2)

        // Target line height so that N lines + (N-1)*spacing fit vertically
        let totalSpacing = CGFloat(max(0, linesCount - 1)) * lineSpacing
        let maxLineHeightFromHeight = (usableHeight - totalSpacing) / CGFloat(linesCount)

        // Also cap by width to avoid overflow on narrow cells
        let maxLineHeightFromWidth = usableWidth * Theme.CardUI.maxWidthGlyphScale

        let targetLineHeight = max(
            Theme.CardUI.minSymbolLineHeight,
            min(maxLineHeightFromHeight, maxLineHeightFromWidth)
        )

        let font = UIFont.systemFont(ofSize: targetLineHeight, weight: .semibold)

        // Paragraph style to center vertically-ish via line spacing
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = lineSpacing

        let uiColor = color(for: card.color)
        let attributes: [NSAttributedString.Key: Any]
        switch card.shading {
        case .solid:
            attributes = [
                .font: font,
                .foregroundColor: uiColor,
                .strokeColor: uiColor,
                .strokeWidth: -3,
                .paragraphStyle: paragraph,
            ]
        case .open:
            attributes = [
                .font: font,
                .foregroundColor: UIColor.clear,
                .strokeColor: uiColor,
                .strokeWidth: 3,
                .paragraphStyle: paragraph,
            ]
        case .striped:
            attributes = [
                .font: font,
                .foregroundColor: uiColor.withAlphaComponent(0.30),
                .strokeColor: uiColor,
                .strokeWidth: -3,
                .paragraphStyle: paragraph,
            ]
        }

        let text = Array(repeating: symbolGlyph, count: linesCount).joined(separator: "\n")
        return NSAttributedString(string: text, attributes: attributes)
    }

    private static func glyph(for symbol: CardSymbol) -> String {
        switch symbol {
        case .diamond: return "▲"
        case .oval: return "●"
        case .squiggle: return "■"
        }
    }

    private static func color(for color: CardColor) -> UIColor {
        switch color {
        case .red: return .systemRed
        case .green: return .systemGreen
        case .purple: return .systemPurple
        }
    }
}
