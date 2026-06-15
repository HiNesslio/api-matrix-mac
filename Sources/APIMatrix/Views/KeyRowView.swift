import SwiftUI

struct KeyRowView: View {
    let key: ApiKeyItem
    @State private var justCopied = false

    private var provider: ProviderDef? { providerDef(for: key.provider) }

    var body: some View {
        HStack(spacing: 10) {
            statusDot
            VStack(alignment: .leading, spacing: 1) {
                Text(provider?.name ?? key.provider)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                HStack(spacing: 4) {
                    Text(key.name)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    if key.isExpired {
                        Text("Expired")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
            }
            .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                copyToClipboard(key.keyValue)
                justCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    justCopied = false
                }
            } label: {
                Text(justCopied ? "Copied" : "Copy")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(justCopied ? .white : Color.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(justCopied ? Color.green : Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var statusDot: some View {
        Circle()
            .fill(key.isExpired ? Color.red : Color.green)
            .frame(width: 6, height: 6)
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
