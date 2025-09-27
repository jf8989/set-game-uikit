// Path: App/Core/Extensions/UIBezierPath+SetShapesExtensions.swift
// Role: Paths for Set shapes + striped fill helper

import UIKit

extension UIBezierPath {

    // MARK: - Diamond & Oval

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

    // MARK: - Squiggle (symmetrical, with optional rotation)

    /// Builds a pleasant S-shaped squiggle proportional to `rect`.
    /// The path is gently rotated around the rect center by `rotationDegrees`.
    static func setSquiggle(in rect: CGRect, rotationDegrees: CGFloat = Theme.CardUI.squiggleRotationDegrees)
        -> UIBezierPath
    {
        // Leave margin so rotation stays inside the rect.
        let insetX = rect.width * 0.06
        let insetY = rect.height * 0.12
        let box = rect.insetBy(dx: insetX, dy: insetY)

        let w = box.width
        let h = box.height
        let x0 = box.minX
        let y0 = box.minY

        // Symmetric control points tuned to look balanced.
        let cA = CGPoint(x: x0 + w * 0.18, y: y0 + h * 0.05)
        let cB = CGPoint(x: x0 + w * 0.42, y: y0 + h * 0.05)
        let cC = CGPoint(x: x0 + w * 0.70, y: y0 + h * 0.30)
        let cD = CGPoint(x: x0 + w * 0.90, y: y0 + h * 0.55)

        let path = UIBezierPath()
        // Left mid → right up
        path.move(to: CGPoint(x: x0 + w * 0.06, y: y0 + h * 0.50))
        path.addCurve(to: CGPoint(x: x0 + w * 0.52, y: y0 + h * 0.18), controlPoint1: cA, controlPoint2: cB)
        // Right up → right mid
        path.addCurve(to: CGPoint(x: x0 + w * 0.96, y: y0 + h * 0.50), controlPoint1: cC, controlPoint2: cD)
        // Right mid → left down (mirror)
        path.addCurve(
            to: CGPoint(x: x0 + w * 0.48, y: y0 + h * 0.82),
            controlPoint1: CGPoint(x: x0 + w * 0.90, y: y0 + h * 0.70),
            controlPoint2: CGPoint(x: x0 + w * 0.70, y: y0 + h * 0.92)
        )
        // Left down → close at left mid
        path.addCurve(
            to: CGPoint(x: x0 + w * 0.06, y: y0 + h * 0.50),
            controlPoint1: CGPoint(x: x0 + w * 0.30, y: y0 + h * 0.78),
            controlPoint2: CGPoint(x: x0 + w * 0.18, y: y0 + h * 0.95)
        )
        path.close()

        // Center the path (defensive) then rotate slightly
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
        let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)

        if rotationDegrees != 0 {
            let radians = rotationDegrees * .pi / 180.0
            path.apply(toOrigin)
            path.apply(CGAffineTransform(rotationAngle: radians))
            path.apply(fromOrigin)
        }

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
