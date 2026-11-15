// Optional asset conversion: swift make-app-icon.swift (run from this directory).
import AppKit

let source = NSImage(contentsOfFile: "AppIcon-iOS.png")!
let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
let iconset = temporary.appendingPathComponent("AppIcon.iconset")
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: temporary) }
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let size = CGFloat(pixels)
        let inset = size / 16
        let frame = NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
        NSBezierPath(roundedRect: frame, xRadius: frame.width * 0.225, yRadius: frame.height * 0.225)
            .addClip()
        source.draw(in: frame, from: .zero, operation: .copy, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        let url = iconset.appendingPathComponent("icon_\(points)x\(points)\(suffix).png")
        try bitmap.representation(using: .png, properties: [:])!.write(to: url)
    }
}
let convert = Process()
convert.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
convert.arguments = ["-c", "icns", iconset.path, "-o", "AppIcon.icns"]
try convert.run()
convert.waitUntilExit()
precondition(convert.terminationStatus == 0)
print("AppIcon.icns ready")
