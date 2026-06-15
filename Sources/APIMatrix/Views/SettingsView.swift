import SwiftUI

struct SettingsView: View {
    @AppStorage("autoLockMinutes") private var autoLockMinutes = 0
    @AppStorage("lightModeOnly") private var lightModeOnly = true

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }
            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 400, height: 300)
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

            Text("A macOS menu bar companion for managing API keys.\nSyncs with the iOS app via shared Keychain.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Link("GitHub", destination: URL(string: "https://github.com/HiNesslio/api-matrix-mac")!)
                .font(.system(size: 12))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
