import SwiftUI

struct MenuBarView: View {
    @Environment(KeychainService.self) private var keychain
    @State private var searchText = ""
    @State private var showAdd = false

    private var filteredKeys: [ApiKeyItem] {
        guard !searchText.isEmpty else { return keychain.keys }
        return keychain.keys.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.provider.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $searchText)

            Divider()

            if filteredKeys.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredKeys) { key in
                            KeyRowView(key: key)
                            if key.id != filteredKeys.last?.id {
                                Divider().padding(.leading, 28)
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }

            Divider()

            HStack(spacing: 8) {
                Button {
                    showAdd = true
                } label: {
                    Label("Add Key", systemImage: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button {
                    (NSApp.delegate as? AppDelegate)?.openMainWindow()
                } label: {
                    Text("Open Full App")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.textBackgroundColor))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separatorColor), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Button {
                NSApp.terminate(nil)
            } label: {
                Text("Quit")
                    .font(.system(size: 11))
                    .frame(maxWidth: .infinity)
                    .padding(6)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
        }
        .frame(width: 360)
        .sheet(isPresented: $showAdd) {
            AddKeyView()
        }
    }
}
