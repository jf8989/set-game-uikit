// App/Core/AppFeatures/GameScreen/Managers/SetGameLayoutBuilder.swift
import UIKit

struct SetGameLayoutBuilder {
    let header: HeaderView
    let grid: UICollectionView
    let toolbar: GameToolbarView

    func install(in root: UIView, safe: UILayoutGuide, padding: CGFloat) {
        // Add subviews
        [header, grid, toolbar].forEach { root.addSubview($0) }

        header.translatesAutoresizingMaskIntoConstraints = false
        grid.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Header at top
            header.topAnchor.constraint(equalTo: safe.topAnchor, constant: padding),
            header.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            header.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),

            // Toolbar at bottom
            toolbar.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            toolbar.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            toolbar.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -padding),

            // Grid fills the middle
            grid.topAnchor.constraint(equalTo: header.bottomAnchor, constant: padding),
            grid.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            grid.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            grid.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -padding),
        ])

        // Example of view priorities if you still want them:
        grid.setContentHuggingPriority(.defaultLow, for: .vertical)
        grid.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
