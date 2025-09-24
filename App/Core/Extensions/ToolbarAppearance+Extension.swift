// App/Core/AppFeatures/GameScreen/Helpers/ToolbarAppearance.swift
import UIKit

enum ToolbarStyle {
    case solid(background: UIColor = .systemBackground)
    case translucent(blur: UIBlurEffect.Style = .systemMaterial)
}

extension UIToolbar {
    @discardableResult
    func applying(_ style: ToolbarStyle) -> Self {
        translatesAutoresizingMaskIntoConstraints = false

        // Legacy (pre-iOS 13)
        guard #available(iOS 13.0, *) else {
            switch style {
            case .solid(let backgroundColor):
                isTranslucent = false
                barTintColor = backgroundColor
            case .translucent:
                isTranslucent = true
            }
            setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            setShadowImage(UIImage(), forToolbarPosition: .any)
            return self
        }

        // iOS 13+
        let appearance = UIToolbarAppearance()
        appearance.shadowColor = .clear

        switch style {
        case .solid(let backgroundColor):
            isTranslucent = false
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
        case .translucent(let blurEffectStyle):
            isTranslucent = true
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: blurEffectStyle)
        }

        standardAppearance = appearance
        compactAppearance = appearance
        scrollEdgeAppearance = appearance
        compactScrollEdgeAppearance = appearance
        return self
    }
}
