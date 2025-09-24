// App/Core/AppFeatures/GameScreen/Helpers/ToolbarAppearance.swift
import UIKit

enum ToolbarStyle {
    case solid(background: UIColor = .systemBackground)
    case translucent(blur: UIBlurEffect.Style = .systemMaterial)
}

@inline(__always)
func applyToolbarAppearance(_ toolbar: UIToolbar, style: ToolbarStyle) {
    toolbar.translatesAutoresizingMaskIntoConstraints = false

    // Legacy path first
    guard #available(iOS 13.0, *) else {
        // Best-effort on old iOS: remove hairline; choose translucency
        switch style {
        case .solid(let background):
            toolbar.isTranslucent = false
            toolbar.barTintColor = background
        case .translucent:
            toolbar.isTranslucent = true
        }
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        return
    }

    // Modern path
    let appearance = UIToolbarAppearance()
    appearance.shadowColor = .clear

    switch style {
    case .solid(let background):
        toolbar.isTranslucent = false
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = background

    case .translucent(let blurStyle):
        toolbar.isTranslucent = true
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: blurStyle)
    }

    toolbar.standardAppearance = appearance
    toolbar.compactAppearance = appearance
    toolbar.scrollEdgeAppearance = appearance
    toolbar.compactScrollEdgeAppearance = appearance
}
