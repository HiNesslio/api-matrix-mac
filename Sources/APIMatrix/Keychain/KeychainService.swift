import Foundation
import Security
import OSLog

private let log = Logger(subsystem: "com.apimatrix.mac", category: "Keychain")

@Observable
final class KeychainService {
    private let metaKey = "apikeyvault_keys_meta"
    private let keyPrefix = "apikeyvault_key_"
    private let accessGroup: String? = {
        guard let teamId = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String else {
            log.warning("AppIdentifierPrefix not found — running unsigned")
            return nil
        }
        return "\(teamId)com.apimatrix.app"
    }()

    var keys: [ApiKeyItem] = []
    var lastError: String?

    init() {
        log.debug("KeychainService init, accessGroup=\(self.accessGroup ?? "nil", privacy: .public)")
        loadAllKeys()
    }

    func loadAllKeys() {
        do {
            let ids = try readMeta()
            log.debug("Meta IDs: \(ids.count)")
            keys = try ids.compactMap { try readKey(id: $0) }
            log.debug("Loaded \(self.keys.count) keys")
            lastError = nil
        } catch let e as KeychainError {
            if case .unexpectedStatus(let s) = e, s == errSecItemNotFound {
                keys = []
                lastError = nil
                log.debug("No existing keys found")
            } else if case .itemNotFound = e {
                keys = []
                lastError = nil
            } else {
                lastError = e.localizedDescription
                log.error("loadAllKeys error: \(e.localizedDescription, privacy: .public)")
            }
        } catch {
            lastError = error.localizedDescription
            log.error("loadAllKeys generic error: \(error.localizedDescription, privacy: .public)")
        }
    }

    func getKey(id: String) -> ApiKeyItem? {
        keys.first { $0.id == id }
    }

    func saveKey(_ key: ApiKeyItem) {
        log.debug("saveKey: \(key.id, privacy: .public)")
        do {
            try writeKey(key)
            log.debug("writeKey succeeded")
            let ids = (try? readMeta()) ?? []
            log.debug("readMeta returned \(ids.count) existing IDs")
            if !ids.contains(key.id) {
                var newIds = ids
                newIds.append(key.id)
                try writeMeta(newIds)
                log.debug("writeMeta succeeded, IDs now: \(newIds.count)")
            }
            loadAllKeys()
            log.debug("saveKey complete — keys count: \(self.keys.count)")
        } catch {
            lastError = error.localizedDescription
            log.error("saveKey failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func deleteKey(id: String) {
        do {
            try deleteKeyFromKeychain(id: id)
            var ids = (try? readMeta()) ?? []
            ids.removeAll { $0 == id }
            try writeMeta(ids)
            loadAllKeys()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func reorderKeys(_ orderedIds: [String]) {
        do {
            try writeMeta(orderedIds)
            loadAllKeys()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func readMeta() throws -> [String] {
        let data = try readKeychain(key: metaKey)
        return try JSONDecoder().decode([String].self, from: data)
    }

    private func writeMeta(_ ids: [String]) throws {
        let data = try JSONEncoder().encode(ids)
        try writeKeychain(key: metaKey, data: data)
    }

    private func readKey(id: String) throws -> ApiKeyItem? {
        let data = try readKeychain(key: "\(keyPrefix)\(id)")
        return try JSONDecoder().decode(ApiKeyItem.self, from: data)
    }

    private func writeKey(_ key: ApiKeyItem) throws {
        let data = try JSONEncoder().encode(key)
        try writeKeychain(key: "\(keyPrefix)\(key.id)", data: data)
    }

    private func withAccessGroup(_ query: [String: Any]) -> [String: Any] {
        guard let group = accessGroup else { return query }
        var q = query
        q[kSecAttrAccessGroup as String] = group
        return q
    }

    private func deleteKeyFromKeychain(id: String) throws {
        let query = withAccessGroup([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(keyPrefix)\(id)",
            kSecAttrService as String: metaKey,
        ])
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func readKeychain(key: String) throws -> Data {
        let query = withAccessGroup([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: metaKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ])
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            log.error("readKeychain(\(key, privacy: .public)) status=\(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        return data
    }

    private func writeKeychain(key: String, data: Data) throws {
        let query = withAccessGroup([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: metaKey,
        ])
        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            log.debug("writeKeychain(\(key, privacy: .public)) exists — updating")
            SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        } else {
            var newQuery = query
            newQuery[kSecValueData as String] = data
            newQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            log.debug("writeKeychain(\(key, privacy: .public)) new — adding")
            let addStatus = SecItemAdd(newQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                log.error("writeKeychain(\(key, privacy: .public)) add failed status=\(addStatus)")
                throw KeychainError.unexpectedStatus(addStatus)
            }
        }
    }
}

enum KeychainError: LocalizedError {
    case itemNotFound
    case invalidData
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .itemNotFound: return "No data found in Keychain"
        case .invalidData: return "Failed to decode Keychain data"
        case .unexpectedStatus(let status): return "Keychain error: \(status)"
        }
    }
}
