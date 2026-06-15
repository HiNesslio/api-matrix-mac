import SwiftUI

@main
struct APIMatrixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("lightModeOnly") private var lightModeOnly = true

    private var colorScheme: ColorScheme? {
        lightModeOnly ? .light : nil
    }

    var body: some Scene {
        Window("API Matrix", id: "main-window") {
            MainWindowView()
                .environment(AppState.shared.keychain)
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
                .environment(AppState.shared.keychain)
        }
    }
}

final class AppState: @unchecked Sendable {
    static let shared = AppState()
    let keychain = KeychainService()
    let autoLock = AutoLockService()
}

extension NSApplication {
    @objc func showMainWindow() {
        NSApp.sendAction(Selector(("showMainWindow:")), to: nil, from: nil)
    }
}
