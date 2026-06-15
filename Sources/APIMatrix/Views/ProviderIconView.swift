import SwiftUI
import OSLog

private let log = Logger(subsystem: "com.apimatrix.mac", category: "Icon")

struct ProviderIconView: View {
    let providerID: String
    let size: CGFloat

    init(_ providerID: String, size: CGFloat = 16) {
        self.providerID = providerID
        self.size = size
    }

    var body: some View {
        if let image = Self.loadSVG(providerID) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                Text(providerDef(for: providerID)?.name.prefix(1) ?? "?")
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(Color.accentColor)
            )
    }

    private static var cache: [String: NSImage] = [:]

    private static func loadSVG(_ id: String) -> NSImage? {
        if let cached = cache[id] { return cached }

        // Try Bundle.module (SwiftPM resource bundle — SVGs are flat)
        let moduleBundle = findSwiftPMResourceBundle()
        if let b = moduleBundle, let url = b.url(forResource: id, withExtension: "svg") {
            if let image = NSImage(contentsOf: url) { cache[id] = image; return image }
        }

        // Try Bundle.main with ProviderIcons subdirectory (Makefile .app bundle)
        if let url = Bundle.main.url(forResource: id, withExtension: "svg", subdirectory: "ProviderIcons") {
            if let image = NSImage(contentsOf: url) { cache[id] = image; return image }
        }

        // Try Bundle.main flat
        if let url = Bundle.main.url(forResource: id, withExtension: "svg") {
            if let image = NSImage(contentsOf: url) { cache[id] = image; return image }
        }

        log.warning("SVG not found for \(id, privacy: .public)")
        return nil
    }

    /// Safe alternative to Bundle.module that doesn't fatalError when the resource bundle is missing.
    private static func findSwiftPMResourceBundle() -> Bundle? {
        // The generated Bundle.module accessor looks for:
        //   mainPath = Bundle.main.bundleURL + "API Matrix_APIMatrix.bundle"
        //   buildPath = hardcoded absolute path in .build/
        // We replicate this lookup safely using Bundle(path:).

        let mainPath = Bundle.main.bundleURL.appendingPathComponent("API Matrix_APIMatrix.bundle").path
        if let bundle = Bundle(path: mainPath) { return bundle }

        let home = NSHomeDirectory()
        for variant in ["debug", "release"] {
            let buildPath = "\(home)/mvp/api-matrix-mac/.build/arm64-apple-macosx/\(variant)/API Matrix_APIMatrix.bundle"
            if let bundle = Bundle(path: buildPath) { return bundle }
        }

        return nil
    }
}
