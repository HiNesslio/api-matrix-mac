import SwiftUI

struct SidebarView: View {
    @Environment(KeychainService.self) private var keychain
    @Binding var selectedKey: ApiKeyItem?
    @Binding var selectedCategory: ProviderCategory

    private var keysByCategory: [ProviderCategory: [ApiKeyItem]] {
        Dictionary(grouping: keychain.keys) { key in
            providerDef(for: key.provider)?.category ?? .other
        }
    }

    var body: some View {
        List(selection: $selectedKey) {
            ForEach(providerGroups()) { group in
                let groupKeys = keysByCategory[group.id, default: []]
                if !groupKeys.isEmpty {
                    Section(group.id.rawValue) {
                        ForEach(groupKeys) { key in
                            Label {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(providerDef(for: key.provider)?.name ?? key.provider)
                                        .font(.system(size: 12, weight: .medium))
                                    Text(key.name)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                ProviderIconView(key.provider, size: 14)
                            }
                            .tag(key)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }

}
