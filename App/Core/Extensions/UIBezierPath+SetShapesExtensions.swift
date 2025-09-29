// Path: App/Core/Extensions/UIBezierPath+SetShapesExtensions.swift
// Role: Paths for Set shapes + striped fill helper

import UIKit

extension UIBezierPath {

    static func setDiamond(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        return path
    }

    static func setOval(in rect: CGRect) -> UIBezierPath {
        UIBezierPath(roundedRect: rect, cornerRadius: min(rect.width, rect.height) / 2.0)
    }

    /// Builds an S-shaped squiggle proportional to `rect`. Rotation is applied around rect center,
    /// then the path is translated so its bounds are perfectly centered on `rect`.
    static func setSquiggle(
        in rect: CGRect,
        rotationDegrees: CGFloat = SetGameTheme.CardUI.squiggleRotationDegrees
    ) -> UIBezierPath {
        let insetX = rect.width * SetGameTheme.CardUI.SquiggleRatios.insetXFraction
        let insetY = rect.height * SetGameTheme.CardUI.SquiggleRatios.insetYFraction
        let squiggleBox = rect.insetBy(dx: insetX, dy: insetY)

        let boxMinX = squiggleBox.minX
        let boxMinY = squiggleBox.minY
        let boxWidth = squiggleBox.width
        let boxHeight = squiggleBox.height

        func pointForRatio(_ ratio: CGPoint) -> CGPoint {
            CGPoint(x: boxMinX + boxWidth * ratio.x, y: boxMinY + boxHeight * ratio.y)
        }

        let path = UIBezierPath()
        path.move(to: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.startLeftMid))
        path.addCurve(
            to: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.topAnchor),
            controlPoint1: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlPointA),
            controlPoint2: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlPointB)
        )
        path.addCurve(
            to: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.rightMid),
            controlPoint1: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlPointC),
            controlPoint2: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlPointD)
        )
        path.addCurve(
            to: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.bottomAnchor),
            controlPoint1: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlMirror1),
            controlPoint2: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlMirror2)
        )
        path.addCurve(
            to: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.startLeftMid),
            controlPoint1: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlMirror3),
            controlPoint2: pointForRatio(SetGameTheme.CardUI.SquiggleRatios.controlMirror4)
        )
        path.close()

        // Translate the path so its bounds center matches `rect`'s center.
        func recenter(_ path: UIBezierPath, to rect: CGRect) {
            let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
            let translationX = rectCenter.x - path.bounds.midX
            let translationY = rectCenter.y - path.bounds.midY
            guard abs(translationX) > .ulpOfOne || abs(translationY) > .ulpOfOne else { return }
            path.apply(CGAffineTransform(translationX: translationX, y: translationY))
        }

        // Rotate around center, then recenter once.
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
        let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)

        guard rotationDegrees != 0 else {
            recenter(path, to: rect)
            return path
        }

        let radians = rotationDegrees * .pi / 180.0
        path.apply(toOrigin)
        path.apply(CGAffineTransform(rotationAngle: radians))
        path.apply(fromOrigin)

        recenter(path, to: rect)
        return path
    }

    /// Clips to `shape` and draws vertical stripes inside `rect`.
    static func drawStriped(
        in rect: CGRect,
        clip shape: UIBezierPath,
        lineSpacing: CGFloat,
        lineWidth: CGFloat,
        color: UIColor
    ) {
        guard rect.width > 0, rect.height > 0 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        shape.addClip()
        color.setStroke()

        let startX = floor(rect.minX)
        let endX = floor(rect.maxX)
        var currentX = startX

        while currentX <= endX {
            let stripe = UIBezierPath()
            stripe.move(to: CGPoint(x: currentX, y: rect.minY))
            stripe.addLine(to: CGPoint(x: currentX, y: rect.maxY))
            stripe.lineWidth = lineWidth
            stripe.stroke()
            currentX += lineSpacing
        }

        context.restoreGState()
    }
}
