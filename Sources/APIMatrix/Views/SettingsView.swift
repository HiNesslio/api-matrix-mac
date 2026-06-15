import SwiftUI

struct SettingsView: View {
    @Environment(KeychainService.self) private var keychain
    @AppStorage("autoLockMinutes") private var autoLockMinutes = 0
    @AppStorage("lightModeOnly") private var lightModeOnly = true
    @State private var showImportResult = false
    @State private var importMessage = ""

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }
            importExportTab
                .tabItem { Label("Data", systemImage: "arrow.triangle.2.circlepath") }
            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 420, height: 340)
        .alert(importMessage, isPresented: $showImportResult) {
            Button("OK") {}
        }
    }

    private var generalTab: some View {
        Form {
            Picker("Auto-lock", selection: $autoLockMinutes) {
                Text("Never").tag(0)
                Text("1 minute").tag(1)
                Text("5 minutes").tag(5)
                Text("15 minutes").tag(15)
            }

            Toggle("Always use light mode", isOn: $lightModeOnly)

            Text("Auto-lock hides revealed keys after inactivity.")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var importExportTab: some View {
        VStack(spacing: 16) {
            Text("Sync with iOS App")
                .font(.system(size: 13, weight: .semibold))

            Text("iCloud Keychain sync requires both apps to be\nsigned with the same Apple Developer Team.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button {
                    exportKeys()
                } label: {
                    Label("Export Keys", systemImage: "square.and.arrow.up")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button {
                    importKeys()
                } label: {
                    Label("Import Keys", systemImage: "square.and.arrow.down")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.textBackgroundColor))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separatorColor)))
                }
                .buttonStyle(.plain)
            }

            Text("Export saves all keys as JSON to clipboard.\nImport reads JSON from clipboard and merges.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.icloud.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.accentColor)

            Text("API Matrix")
                .font(.system(size: 16, weight: .bold))

            Text("Version 1.0.0")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Link("GitHub", destination: URL(string: "https://github.com/HiNesslio/api-matrix-mac")!)
                .font(.system(size: 12))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func exportKeys() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(keychain.keys),
              let json = String(data: data, encoding: .utf8) else {
            importMessage = "Failed to encode keys."
            showImportResult = true
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(json, forType: .string)
        importMessage = "Exported \(keychain.keys.count) key(s) to clipboard."
        showImportResult = true
    }

    private func importKeys() {
        guard let json = NSPasteboard.general.string(forType: .string) else {
            importMessage = "Clipboard is empty."
            showImportResult = true
            return
        }
        let decoder = JSONDecoder()
        guard let imported = try? decoder.decode([ApiKeyItem].self, from: Data(json.utf8)) else {
            importMessage = "Clipboard doesn't contain valid API key data."
            showImportResult = true
            return
        }
        for key in imported {
            let exists = keychain.keys.contains { $0.id == key.id }
            if !exists {
                keychain.saveKey(key)
            }
        }
        importMessage = "Imported \(imported.count) key(s) from clipboard."
        showImportResult = true
    }
}
