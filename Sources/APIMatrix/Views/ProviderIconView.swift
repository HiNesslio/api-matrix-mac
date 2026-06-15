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
        if let image = loadSVG(providerID) {
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

    private func loadSVG(_ id: String) -> NSImage? {
        guard let url = Bundle.module.url(forResource: id, withExtension: "svg", subdirectory: "ProviderIcons") else {
            log.warning("SVG not found for \(id, privacy: .public) in Bundle.module")
            log.debug("Bundle.main=\(Bundle.main.bundlePath, privacy: .public)")
            log.debug("Bundle.module=\(Bundle.module.bundlePath, privacy: .public)")
            return nil
        }
        if let image = NSImage(contentsOf: url) {
            log.debug("SVG loaded for \(id, privacy: .public) from \(url.lastPathComponent)")
            return image
        } else {
            log.warning("SVG found but NSImage nil for \(id, privacy: .public)")
            return nil
        }
    }
}
