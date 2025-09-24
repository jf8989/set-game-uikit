// App/Core/Extensions/ToolbarAppearance+Extension.swift

import UIKit

enum ToolbarStyle {
    case solid(background: UIColor = .systemBackground)
    case translucent(blur: UIBlurEffect.Style = .systemMaterial)
}

extension UIToolbar {

    var style: ToolbarStyle {
        get {
            // Legacy path first
            guard #available(iOS 13.0, *) else {
                // Pre-iOS 13
                guard isTranslucent else {
                    return .solid(background: barTintColor ?? .white)
                }
                return .translucent(blur: .light)
            }

            // iOS 13+
            guard isTranslucent else {
                let backgroundColor = standardAppearance.backgroundColor ?? .systemBackground
                return .solid(background: backgroundColor)
            }
            return .translucent(blur: .systemMaterial)
        }
        set {
            translatesAutoresizingMaskIntoConstraints = false

            // Legacy path first
            guard #available(iOS 13.0, *) else {
                switch newValue {
                case .solid(let backgroundColor):
                    isTranslucent = false
                    barTintColor = backgroundColor
                case .translucent:
                    isTranslucent = true
                }
                setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
                setShadowImage(UIImage(), forToolbarPosition: .any)
                return
            }

            // iOS 13+
            let appearance = UIToolbarAppearance()
            appearance.shadowColor = .clear

            switch newValue {
            case .solid(let backgroundColor):
                isTranslucent = false
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = backgroundColor

            case .translucent(let blurStyle):
                isTranslucent = true
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = UIBlurEffect(style: blurStyle)
            }

            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
            compactScrollEdgeAppearance = appearance
        }
    }
}
