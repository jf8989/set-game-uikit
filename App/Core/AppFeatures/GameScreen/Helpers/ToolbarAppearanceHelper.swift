// App/Core/AppFeatures/GameScreen/Helpers/ToolbarAppearance.swift
import UIKit

enum ToolbarStyle {
    case solid(background: UIColor = .systemBackground)
    case translucent(blur: UIBlurEffect.Style = .systemMaterial)
}

@inline(__always)
func applyToolbarAppearance(_ toolbar: UIToolbar, style: ToolbarStyle) {
    toolbar.translatesAutoresizingMaskIntoConstraints = false

    switch style {
    case .solid(let background):
        toolbar.isTranslucent = false
        if #available(iOS 13.0, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = background
            appearance.shadowColor = .clear
            toolbar.standardAppearance = appearance
            toolbar.compactAppearance = appearance
            toolbar.scrollEdgeAppearance = appearance
            toolbar.compactScrollEdgeAppearance = appearance
        } else {
            toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        }

    case .translucent(let blurStyle):
        toolbar.isTranslucent = true
        if #available(iOS 13.0, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithTransparentBackground()  // no solid fill
            appearance.backgroundEffect = UIBlurEffect(style: blurStyle)  // the blur
            appearance.shadowColor = .clear  // kill hairline
            toolbar.standardAppearance = appearance
            toolbar.compactAppearance = appearance
            toolbar.scrollEdgeAppearance = appearance
            toolbar.compactScrollEdgeAppearance = appearance
        } else {
            // Older iOS: best-effort “transparent” look (no blur API).
            toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        }
    }
}
