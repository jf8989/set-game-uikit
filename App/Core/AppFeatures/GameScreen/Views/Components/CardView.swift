// Path: App/Core/AppFeatures/GameScreen/Views/CardView.swift
// Role: Render Set card (1–3 symbols; solid/open/striped); accessibility label from model

import UIKit

final class CardView: UIView {

    // MARK: - Model
    var card: CardSet {
        didSet {
            isAccessibilityElement = true
            accessibilityLabel = card.accessibilityLabelText
            setNeedsDisplay()
        }
    }

    // Selection styling hook
    var isSelectionEmphasized: Bool = false {
        didSet {
            // Hide the base layer border when drawing the thick overlay; restore otherwise.
            layer.borderWidth = isSelectionEmphasized ? 0 : SetGameTheme.CardUI.cardBaseBorderWidth
            setNeedsDisplay()
        }
    }

    var selectionOverlayColor: UIColor? {
        didSet { if isSelectionEmphasized { setNeedsDisplay() } }
    }

    // MARK: - Init
    init(card: CardSet) {
        self.card = card
        super.init(frame: .zero)

        isOpaque = true
        backgroundColor = .systemBackground
        layer.cornerRadius = SetGameTheme.CardUI.cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = SetGameTheme.CardUI.cardBaseBorderWidth
        layer.borderColor = UIColor.separator.cgColor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Drawing (orchestrator only)
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let symbolCount = card.number.rawValue
        let metrics = computeGlyphMetrics(in: rect, symbolCount: symbolCount)
        let frames = metrics.frames(count: symbolCount)

        for frame in frames {
            renderSymbol(in: frame, with: card, metrics: metrics, context: context)
        }

        guard isSelectionEmphasized else { return }

        let strokeColor = selectionOverlayColor ?? SetGameTheme.CardUI.selectionColor
        let width = SetGameTheme.CardUI.selectionBorderWidth
        let inset = width / 2.0  // center-aligned stroke: inset by half or it will clip

        let rounded = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: SetGameTheme.CardUI.cornerRadius
        )
        rounded.lineWidth = width
        strokeColor.setStroke()
        rounded.stroke()
    }

    // MARK: - Render Symbols
    fileprivate func renderSymbol(in frame: CGRect, with card: CardSet, metrics: GlyphMetrics, context: CGContext) {
        let baseColor = card.color.uiColor
        let symbolRect = frame.insetBy(dx: metrics.strokeInset, dy: metrics.strokeInset)
        let path = card.symbol.path(in: symbolRect)

        switch card.shading {

        case .solid:
            baseColor.setFill()
            baseColor.setStroke()
            path.lineWidth = metrics.baseStrokeWidth * card.shading.strokeMultiplier
            path.fill()
            path.stroke()

        case .open:
            baseColor.setStroke()
            path.lineWidth = metrics.baseStrokeWidth * card.shading.strokeMultiplier
            path.stroke()

        case .striped:
            baseColor.setStroke()
            path.lineWidth = metrics.baseStrokeWidth * card.shading.strokeMultiplier
            path.stroke()
            let stripeColor = baseColor.withAlphaComponent(card.shading.stripeAlpha)
            let spacing = card.shading.stripeSpacing(for: metrics.glyphSize.height)

            UIBezierPath.drawStriped(
                in: symbolRect,
                clip: path,
                lineSpacing: spacing,
                lineWidth: metrics.baseStrokeWidth,
                color: stripeColor
            )
        }
    }

}

// MARK: - Extensions
extension CardView {

    fileprivate struct GlyphMetrics {
        let contentRect: CGRect
        let glyphSize: CGSize
        let verticalSpacing: CGFloat
        let baseStrokeWidth: CGFloat
        let strokeInset: CGFloat
    }

    fileprivate func computeGlyphMetrics(in bounds: CGRect, symbolCount: Int) -> GlyphMetrics {
        // Scale-aware base stroke
        let screenScale = window?.screen.scale ?? UIScreen.main.scale
        let baseStrokeWidth = max(SetGameTheme.CardUI.minStrokeWidthPoints, 1.0 / screenScale)

        // Size-aware inset & spacing for tiny cards
        let minimumCardSide = min(bounds.width, bounds.height)
        let tinyInset = minimumCardSide * SetGameTheme.CardUI.insetFractionWhenTiny
        let contentInset = min(SetGameTheme.CardUI.contentInset, tinyInset)
        let contentRect = bounds.insetBy(dx: contentInset, dy: contentInset)

        let tinySpacing = contentRect.height * SetGameTheme.CardUI.spacingFractionWhenTiny
        let verticalSpacing = min(SetGameTheme.CardUI.lineSpacing, tinySpacing)

        // Glyph size
        let availableHeight = contentRect.height - CGFloat(symbolCount - 1) * verticalSpacing
        let maximumGlyphWidth = contentRect.width * SetGameTheme.CardUI.maxWidthGlyphScale
        let maximumGlyphHeight = contentRect.height * SetGameTheme.CardUI.glyphMaxHeightFraction
        let glyphHeight = max(
            SetGameTheme.CardUI.minSymbolLineHeight,
            min(availableHeight / CGFloat(symbolCount), maximumGlyphHeight)
        )
        let glyphWidth = min(maximumGlyphWidth, glyphHeight * SetGameTheme.CardUI.glyphAspectWidthToHeight)

        // Keep strokes inside
        let strokeInset = (baseStrokeWidth * card.shading.strokeMultiplier) * 0.5

        return GlyphMetrics(
            contentRect: contentRect,
            glyphSize: CGSize(width: glyphWidth, height: glyphHeight),
            verticalSpacing: verticalSpacing,
            baseStrokeWidth: baseStrokeWidth,
            strokeInset: strokeInset
        )
    }
}

extension CardView.GlyphMetrics {
    /// Row-major frames, horizontally centered and block-centered vertically.
    fileprivate func frames(count: Int) -> [CGRect] {
        guard count > 0 else { return [] }

        let totalBlockHeight = CGFloat(count) * glyphSize.height + CGFloat(count - 1) * verticalSpacing
        let startY = round(contentRect.midY - totalBlockHeight / 2.0)
        let centerX = contentRect.midX

        var frames: [CGRect] = []
        frames.reserveCapacity(count)

        var currentY = startY
        for symbolIndex in 0..<count {
            _ = symbolIndex
            let originX = round(centerX - glyphSize.width / 2.0)
            frames.append(CGRect(origin: CGPoint(x: originX, y: currentY), size: glyphSize))
            currentY += glyphSize.height + verticalSpacing
        }
        return frames
    }
}
