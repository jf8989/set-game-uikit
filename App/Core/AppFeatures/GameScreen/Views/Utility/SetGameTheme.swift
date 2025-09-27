// App/Core/AppFeatures/GameScreen/Views/Utility/Theme.swift

import UIKit

enum Theme {

    enum Layout {
        static let outerPadding: CGFloat = 12
        static let interitem: CGFloat = 6
        static let lineSpacing: CGFloat = 6
        static let cardAspectRatio: CGFloat = 2.0 / 3.0
    }

    enum CardUI {
        static let cornerRadius: CGFloat = 16

        // Content geometry (base)
        static let contentInset: CGFloat = 12
        static let lineSpacing: CGFloat = 6

        // Scale down inset/spacing when cards are tiny (e.g., 81 on screen)
        static let insetFractionWhenTiny: CGFloat = 0.06  // percent of min(cardSide)
        static let spacingFractionWhenTiny: CGFloat = 0.04  // percent of content height

        // Glyph sizing
        static let minSymbolLineHeight: CGFloat = 12
        static let glyphMaxHeightFraction: CGFloat = 0.28  // of content rect height
        static let glyphAspectWidthToHeight: CGFloat = 2.0  // ≈ 2:1 width:height
        static let maxWidthGlyphScale: CGFloat = 0.58

        // Strokes & stripes
        static let minStrokeWidthPoints: CGFloat = 1.0
        static let stripeSpacingPerGlyphHeight: CGFloat = 0.10
        static let stripeAlpha: CGFloat = 0.9

        // Squiggle presentation
        static let squiggleRotationDegrees: CGFloat = 20  // set 0 for classic look

        struct SquiggleRatios {
            // Margin to keep rotation inside bounds
            static let insetXFraction: CGFloat = 0.06
            static let insetYFraction: CGFloat = 0.12

            // Anchor points (as fractions of the squiggle box)
            static let startLeftMid = CGPoint(x: 0.06, y: 0.50)
            static let topAnchor = CGPoint(x: 0.52, y: 0.18)
            static let rightMid = CGPoint(x: 0.96, y: 0.50)
            static let bottomAnchor = CGPoint(x: 0.48, y: 0.82)

            // Control points (first half)
            static let controlPointA = CGPoint(x: 0.18, y: 0.05)
            static let controlPointB = CGPoint(x: 0.42, y: 0.05)
            static let controlPointC = CGPoint(x: 0.70, y: 0.30)
            static let controlPointD = CGPoint(x: 0.90, y: 0.55)

            // Control points (mirror half)
            static let controlMirror1 = CGPoint(x: 0.90, y: 0.70)
            static let controlMirror2 = CGPoint(x: 0.70, y: 0.92)
            static let controlMirror3 = CGPoint(x: 0.30, y: 0.78)
            static let controlMirror4 = CGPoint(x: 0.18, y: 0.95)
        }

        static let cardBaseBorderWidth: CGFloat = 2.0

        // Selection overlay
        static let selectionBorderWidth: CGFloat = 6
        static let selectionColor: UIColor = .systemBlue
    }

    enum HeaderUI {
        static let labelTextStyle: UIFont.TextStyle = .title3
        static let labelNumberOfLines: Int = 1
        static let labelMinScaleFactor: CGFloat = 0.85
        static let labelHuggingPriority: UILayoutPriority = .required
        static let labelCompressionPriority: UILayoutPriority = .required

        // If you ever want to theme the toolbar look from Theme too:
        static let toolbarStyle: ToolbarStyle = .translucent(blur: .systemMaterial)
    }
}
