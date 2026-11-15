// Matches the Books widget icon geometry; renders the original Music mark as a vector.
import AppKit

let here = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let svg = try String(contentsOf: here.appendingPathComponent("Icons/audio-waveform.svg"), encoding: .utf8)
let pathData = svg.components(separatedBy: "<path d=\"")[1].components(separatedBy: "\"")[0]
let pattern = try NSRegularExpression(pattern: #"[MLHVZ]|[-+]?(?:\d*\.)?\d+"#)
let tokens = pattern.matches(in: pathData, range: NSRange(pathData.startIndex..., in: pathData)).map {
    (pathData as NSString).substring(with: $0.range)
}
var vertices: [NSPoint] = []
var cursor = NSPoint.zero
var tokenIndex = 0
while tokenIndex < tokens.count {
    let command = tokens[tokenIndex]
    tokenIndex += 1
    switch command {
    case "M", "L":
        cursor = NSPoint(x: Double(tokens[tokenIndex])!, y: Double(tokens[tokenIndex + 1])!)
        tokenIndex += 2
    case "H":
        cursor.x = Double(tokens[tokenIndex])!
        tokenIndex += 1
    case "V":
        cursor.y = Double(tokens[tokenIndex])!
        tokenIndex += 1
    case "Z": continue
    default: fatalError("Unsupported SVG command")
    }
    vertices.append(cursor)
}
let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
let iconset = temporary.appendingPathComponent("AppIcon.iconset")
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: temporary) }
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let size = CGFloat(pixels)
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSColor(calibratedRed: 0.075, green: 0.075, blue: 0.105, alpha: 1).setFill()
        NSBezierPath(
            roundedRect: NSRect(x: 0, y: 0, width: size, height: size).insetBy(
                dx: size * 0.035, dy: size * 0.035),
            xRadius: size * 0.21, yRadius: size * 0.21
        ).fill()
        let mark = NSBezierPath()
        for (index, vertex) in vertices.enumerated() {
            let point = NSPoint(
                x: size * 0.24 + vertex.x / 24 * size * 0.52,
                y: size * 0.24 + (24 - vertex.y) / 24 * size * 0.52)
            if index == 0 { mark.move(to: point) } else { mark.line(to: point) }
        }
        mark.close()
        NSColor.yellow.setFill()
        mark.fill()
        NSGraphicsContext.restoreGraphicsState()
        let data = bitmap.representation(using: .png, properties: [:])!
        let suffix = scale == 2 ? "@2x" : ""
        try data.write(to: iconset.appendingPathComponent("icon_\(points)x\(points)\(suffix).png"))
        if pixels == 1024 { try data.write(to: here.appendingPathComponent("AppIcon-preview.png")) }
    }
}
let convert = Process()
convert.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
convert.arguments = ["-c", "icns", iconset.path, "-o", here.appendingPathComponent("AppIcon.icns").path]
try convert.run()
convert.waitUntilExit()
precondition(convert.terminationStatus == 0)
