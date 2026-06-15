import SwiftUI

struct MainWindowView: View {
    @Environment(KeychainService.self) private var keychain
    @State private var selectedKey: ApiKeyItem?
    @State private var selectedCategory = ProviderCategory.all
    @State private var showAdd = false

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedKey: $selectedKey,
                selectedCategory: $selectedCategory
            )
        } detail: {
            if let key = selectedKey {
                DetailPanelView(key: key)
                    .id(key.id)
            } else {
                ContentUnavailableView(
                    "Select a Key",
                    systemImage: "key.fill",
                    description: Text("Choose an API key from the sidebar")
                )
            }
        }
        .navigationTitle("API Matrix")
        .sheet(isPresented: $showAdd) {
            AddKeyView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .addKeyRequested)) { _ in
            showAdd = true
        }
    }
}

extension Notification.Name {
    static let addKeyRequested = Notification.Name("addKeyRequested")
    static let searchFocusRequested = Notification.Name("searchFocusRequested")
}
