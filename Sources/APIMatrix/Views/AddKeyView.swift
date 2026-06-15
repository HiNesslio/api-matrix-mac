import SwiftUI

struct AddKeyView: View {
    @Environment(KeychainService.self) private var keychain
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProvider: ProviderDef?
    @State private var name = ""
    @State private var keyValue = ""
    @State private var expiresAt: Date?
    @State private var hasExpiry = false
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Provider") {
                    providerPicker
                }

                Section("Key Details") {
                    TextField("Name (e.g. Production)", text: $name)
                    SecureField("API Key", text: $keyValue)
                }

                Section("Optional") {
                    Toggle("Set expiration date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expires", selection: Binding(
                            get: { expiresAt ?? Date().addingTimeInterval(365 * 86400) },
                            set: { expiresAt = $0 }
                        ), displayedComponents: .date)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add API Key")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
        }
        .frame(width: 420, height: 480)
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK") { dismiss() }
        }
    }

    private var providerPicker: some View {
        HStack {
            if let p = selectedProvider {
                ProviderIconView(p.id, size: 18)
            }
            Picker("Provider", selection: $selectedProvider) {
                Text("Select...").tag(nil as ProviderDef?)
                ForEach(allProviders) { provider in
                    Text(provider.name).tag(provider as ProviderDef?)
                }
            }
            .labelsHidden()
        }
    }

    private var isValid: Bool {
        selectedProvider != nil && !name.isEmpty && !keyValue.isEmpty
    }

    private func save() {
        guard let provider = selectedProvider, isValid else { return }
        let key = ApiKeyItem(
            id: "\(provider.id)_\(Int(Date().timeIntervalSince1970))_\(Int.random(in: 1000...9999))",
            provider: provider.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            keyValue: keyValue.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(),
            expiresAt: hasExpiry ? expiresAt : nil,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        keychain.saveKey(key)
        if let error = keychain.lastError {
            alertMessage = error
            showingAlert = true
        } else {
            dismiss()
        }
    }
}
