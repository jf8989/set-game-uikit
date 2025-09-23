// App/Core/AppFeatures/GameScreen/Views/Utility/SetGameLayoutBuilder.swift

import UIKit

struct SetGameLayoutBuilder {
    let header: HeaderView
    let grid: UICollectionView
    let toolbar: GameToolbarView

    func install(in root: UIView, safe: UILayoutGuide, padding: CGFloat) {
        // Add grid first so it sits behind the bars.
        [grid, header, toolbar].forEach {
            root.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Header at top (safe area)
            header.topAnchor.constraint(equalTo: safe.topAnchor, constant: padding),
            header.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            header.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),

            // Toolbar at bottom (safe area)
            toolbar.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            toolbar.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            toolbar.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -padding),

            // Grid runs edge-to-edge, underneath both bars
            grid.topAnchor.constraint(equalTo: root.topAnchor),
            grid.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            grid.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            grid.bottomAnchor.constraint(equalTo: root.bottomAnchor),
        ])

        // Protect against future add-order changes.
        root.bringSubviewToFront(header)
        root.bringSubviewToFront(toolbar)
    }
}
