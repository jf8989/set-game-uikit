// App/Core/AppFeatures/GameScreen/Views/Theme.swift

import UIKit

enum Theme {

    enum Layout {
        static let outerPadding: CGFloat = 12
        static let interitem: CGFloat = 6
        static let lineSpacing: CGFloat = 6
        static let freezeAtCount: Int = 30
        static let cardAspectRatio: CGFloat = 2.0 / 3.0
    }

    enum CardUI {
        static let cornerRadius: CGFloat = 16
        static let contentInset: CGFloat = 12
        static let lineSpacing: CGFloat = 6
        static let minSymbolLineHeight: CGFloat = 12
        static let maxWidthGlyphScale: CGFloat = 0.58
    }
}
