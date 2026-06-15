import SwiftUI

struct ExportSectionView: View {
    let key: ApiKeyItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUICK EXPORT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ExportButton(label: "curl", action: copyCurl)
                ExportButton(label: ".env", action: copyEnv)
                ExportButton(label: "JSON", action: copyJson)
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private var envName: String {
        key.provider.uppercased().replacingOccurrences(of: "-", with: "_") + "_API_KEY"
    }

    private func copyCurl() {
        let curl = """
        curl -H "Authorization: Bearer $\(envName)" https://api.\(key.provider).com/v1/...
        """
        copyToClipboard(curl)
    }

    private func copyEnv() {
        copyToClipboard("\(envName)=\(key.keyValue)")
    }

    private func copyJson() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(key),
           let str = String(data: data, encoding: .utf8) {
            copyToClipboard(str)
        }
    }
}

struct ExportButton: View {
    let label: String
    let action: () -> Void
    @State private var copied = false

    var body: some View {
        Button {
            action()
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Text(copied ? "Copied" : label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(copied ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(copied ? Color.green : Color(.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.separatorColor), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
