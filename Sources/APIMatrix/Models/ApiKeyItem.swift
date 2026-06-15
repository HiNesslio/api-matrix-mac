import Foundation

struct ApiKeyItem: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let provider: String
    var name: String
    var keyValue: String
    let createdAt: Date
    var expiresAt: Date?
    var notes: String?
}

extension ApiKeyItem {
    var maskedKey: String {
        guard keyValue.count > 8 else { return String(repeating: "\u{2022}", count: keyValue.count) }
        let prefix = String(keyValue.prefix(4))
        let suffix = String(keyValue.suffix(4))
        let bullets = String(repeating: "\u{2022}", count: min(12, keyValue.count - 8))
        return "\(prefix)\(bullets)\(suffix)"
    }

    var isExpired: Bool {
        guard let expiresAt else { return false }
        return expiresAt < Date()
    }

    var expiresSoon: Bool {
        guard let expiresAt else { return false }
        return expiresAt > Date() && expiresAt.timeIntervalSinceNow < 7 * 86400
    }
}
