import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var autoLock = AppState.shared.autoLock

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        autoLock.startMonitoring()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "key.icloud.fill", accessibilityDescription: "API Matrix")
            button.action = #selector(togglePopover)
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 500)
        popover.behavior = .transient
        let contentView = MenuBarView()
            .environment(AppState.shared.keychain)
            .preferredColorScheme(.light)
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
    }

    @objc private func togglePopover() {
        guard let popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
        autoLock.registerActivity()
    }

    @objc func openMainWindow() {
        if let popover, popover.isShown {
            popover.performClose(nil)
        }
        let window = NSApp.windows.first { $0.identifier?.rawValue == "main-window" }
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
