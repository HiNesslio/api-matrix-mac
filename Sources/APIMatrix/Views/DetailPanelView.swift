import SwiftUI

struct DetailPanelView: View {
    let key: ApiKeyItem
    @Environment(KeychainService.self) private var keychain
    @State private var showFullKey = false
    @State private var autoHideTask: DispatchWorkItem?
    @State private var justCopied = false
    @State private var showDeleteConfirm = false
    @State private var showEdit = false
    @State private var editName: String = ""
    @State private var editNotes: String = ""
    @State private var editExpiresAt: Date = Date()
    @State private var editHasExpiry = false

    private var provider: ProviderDef? { providerDef(for: key.provider) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                keyDisplay
                metadataGrid
                ExportSectionView(key: key)
            }
            .padding(24)
        }
        .sheet(isPresented: $showEdit) {
            editSheet
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    statusDot
                    Text(provider?.name ?? key.provider)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                Text(key.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
            Spacer()
            HStack(spacing: 6) {
                copyButton
                editButton
                deleteButton
            }
        }
    }

    private var statusDot: some View {
        Circle()
            .fill(key.isExpired ? Color.red : Color.green)
            .frame(width: 6, height: 6)
    }

    private var keyDisplay: some View {
        HStack {
            Text(showFullKey ? key.keyValue : key.maskedKey)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
            Spacer()
            Button {
                showFullKey.toggle()
                if showFullKey {
                    autoHideTask?.cancel()
                    let task = DispatchWorkItem { showFullKey = false }
                    autoHideTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
                } else {
                    autoHideTask?.cancel()
                }
            } label: {
                Image(systemName: showFullKey ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(.textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var metadataGrid: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 12) {
            metadataCard(label: "Created", value: key.createdAt.formatted(date: .numeric, time: .omitted))
            metadataCard(label: key.expiresAt != nil ? "Expires" : "No Expiry", value: key.expiresAt?.formatted(date: .numeric, time: .omitted) ?? "\u{2014}")
            metadataCard(label: "Status", value: key.isExpired ? "Expired" : "Active", color: key.isExpired ? .red : .green)
            if let notes = key.notes, !notes.isEmpty {
                metadataCard(label: "Notes", value: notes)
                    .gridCellColumns(3)
            }
        }
    }

    private func metadataCard(label: String, value: String, color: Color? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color ?? .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var copyButton: some View {
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(key.keyValue, forType: .string)
            justCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { justCopied = false }
        } label: {
            Text(justCopied ? "Copied" : "Copy Key")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(justCopied ? Color.green : Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var editButton: some View {
        Button("Edit") {
            editName = key.name
            editNotes = key.notes ?? ""
            editHasExpiry = key.expiresAt != nil
            editExpiresAt = key.expiresAt ?? Date().addingTimeInterval(365 * 86400)
            showEdit = true
        }
            .font(.system(size: 12))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separatorColor)))
            .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 12))
                .foregroundStyle(.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .confirmationDialog("Delete Key?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                keychain.deleteKey(id: key.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(key.name)\" from \(provider?.name ?? key.provider)? This cannot be undone.")
        }
    }

    private var editSheet: some View {
        NavigationStack {
            Form {
                Section("Key Details") {
                    TextField("Name", text: $editName)
                }
                Section("Optional") {
                    Toggle("Set expiration date", isOn: $editHasExpiry)
                    if editHasExpiry {
                        DatePicker("Expires", selection: $editExpiresAt, displayedComponents: .date)
                    }
                    TextField("Notes", text: $editNotes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Key")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showEdit = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEdit() }
                        .disabled(editName.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }

    private func saveEdit() {
        var updated = key
        updated.name = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.expiresAt = editHasExpiry ? editExpiresAt : nil
        updated.notes = editNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        if updated.notes?.isEmpty ?? false { updated.notes = nil }
        keychain.saveKey(updated)
        showEdit = false
    }
}

#Preview {
    DetailPanelView(key: ApiKeyItem(
        id: "test", provider: "openai", name: "Production",
        keyValue: "sk-proj-abcdefghijklmnopqrstuvwxyz1234567890abcd",
        createdAt: Date()
    ))
    .frame(width: 500, height: 400)
}
