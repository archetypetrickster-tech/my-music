import AppKit

// Visual tokens shared with the settings screens in the Books widget (bridge.js).
enum PanelStyle {
    static let gap: CGFloat = 16
    static let radius: CGFloat = 8
    static let secondary = NSColor(calibratedRed: 0.725, green: 0.725, blue: 0.765, alpha: 1)
    static let muted = NSColor(calibratedRed: 0.573, green: 0.573, blue: 0.620, alpha: 1)

    static func row(_ title: String, control: NSControl) -> NSView {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 13)
        label.textColor = secondary
        control.setAccessibilityLabel(title)
        control.setContentHuggingPriority(.required, for: .horizontal)
        let row = NSStackView(views: [label, NSView(), control])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        row.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return row
    }

    static func back(_ button: NSButton) {
        button.isBordered = false
        button.font = .systemFont(ofSize: 12, weight: .medium)
        button.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        button.imagePosition = .imageLeading
        button.imageHugsTitle = true
        button.alignment = .left
        button.contentTintColor = secondary
        button.focusRingType = .none
    }
}

final class PanelActionButton: HoverButton {
    var plain = false
    override var intrinsicContentSize: NSSize {
        let measured = (title as NSString).size(withAttributes: [.font: font ?? NSFont.systemFont(ofSize: 13)]
        )
        return NSSize(width: measured.width + 24 + (image == nil ? 0 : 20), height: plain ? 28 : 34)
    }
    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        NSColor.white.withAlphaComponent((plain ? 0 : 0.045) + hoverAmount * 0.055 + pressAmount * 0.04)
            .setFill()
        let path = NSBezierPath(roundedRect: rect, xRadius: PanelStyle.radius, yRadius: PanelStyle.radius)
        path.fill()
        if !plain {
            NSColor.white.withAlphaComponent(0.06).setStroke()
            path.lineWidth = 1
            path.stroke()
        }
        let textFont = font ?? .systemFont(ofSize: 13)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: isEnabled ? PanelStyle.secondary : PanelStyle.muted.withAlphaComponent(0.4),
        ]
        let size = (title as NSString).size(withAttributes: attributes)
        let x = alignment == .left ? CGFloat(12) : (bounds.width - size.width) / 2
        if let image {
            IconLibrary.draw(
                image, in: NSRect(x: 10, y: bounds.midY - 6, width: 12, height: 12),
                color: PanelStyle.secondary)
        }
        (title as NSString).draw(
            at: NSPoint(x: x + (image == nil ? 0 : 18), y: bounds.midY - size.height / 2),
            withAttributes: attributes)
    }
}

final class PanelDocumentView: NSView {
    override var isFlipped: Bool { true }
}
