// App/Core/AppFeatures/GameScreen/Views/Utility/SetGameLayoutBuilder.swift
// Role: Replace grid with board; header/top, toolbar/bottom, board in between

import UIKit

struct SetGameLayoutBuilder {
    let header: HeaderView
    let board: CardBoardView
    let toolbar: BottomToolbarView

    func install(in root: UIView, safe: UILayoutGuide, padding: CGFloat) {
        [header, board, toolbar].forEach {
            root.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Header at top (safe area)
            header.topAnchor.constraint(equalTo: safe.topAnchor, constant: padding),
            header.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            header.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),

            // Board between header and toolbar
            board.topAnchor.constraint(equalTo: header.bottomAnchor, constant: padding),
            board.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            board.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            board.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -padding),

            // Toolbar at bottom (safe area)
            toolbar.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: padding),
            toolbar.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -padding),
            toolbar.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -padding),
        ])
    }
}
