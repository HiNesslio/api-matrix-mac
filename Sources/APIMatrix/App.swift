import SwiftUI

@main
struct APIMatrixApp: App {
    @State private var keychain = KeychainService()
    @State private var autoLock = AutoLockService()
    @AppStorage("lightModeOnly") private var lightModeOnly = true

    private var colorScheme: ColorScheme? {
        lightModeOnly ? .light : nil
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(keychain)
                .onAppear { autoLock.startMonitoring() }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    autoLock.registerActivity()
                }
                .preferredColorScheme(colorScheme)
        } label: {
            Label("API Matrix", systemImage: "key.icloud.fill")
        }
        .menuBarExtraStyle(.window)

        Window("API Matrix", id: "main-window") {
            MainWindowView()
                .environment(keychain)
                .onAppear { NSApp.keyWindow?.makeFirstResponder(nil) }
                .preferredColorScheme(colorScheme)
        }
        .defaultSize(width: 760, height: 520)
        .keyboardShortcut("1", modifiers: [.command, .shift])
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add Key") {
                    NotificationCenter.default.post(name: .addKeyRequested, object: nil)
                }
                .keyboardShortcut("n")
            }
            CommandGroup(replacing: .textEditing) {
                Button("Focus Search") {
                    NotificationCenter.default.post(name: .searchFocusRequested, object: nil)
                }
                .keyboardShortcut("f")
            }
        }

        Settings {
            SettingsView()
                .environment(keychain)
        }
    }
}
