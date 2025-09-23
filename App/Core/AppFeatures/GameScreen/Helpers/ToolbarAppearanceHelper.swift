// App/Core/AppFeatures/GameScreen/Helpers/ToolbarAppearanceHelper.swift

import UIKit

@inline(__always)
func applySolidToolbarAppearanceHelper(_ toolbar: UIToolbar, background: UIColor = .systemBackground) {
    if #available(iOS 13.0, *) {
        let ap = UIToolbarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = background
        ap.shadowColor = .clear
        toolbar.standardAppearance = ap
        toolbar.scrollEdgeAppearance = ap
        toolbar.compactAppearance = ap
        toolbar.compactScrollEdgeAppearance = ap
    } else {
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
}
