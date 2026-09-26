import SwiftUI

struct SettingsView: View {
    @Environment(\.appPalette) private var palette
    @Binding private var userDuas: [UserDua]

    @State private var draftUserDuas: [UserDua]
    @State private var savedUserDuas: [UserDua]
    @State private var hasUnsavedChanges = false
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""

    init(userDuas: Binding<[UserDua]>) {
        self._userDuas = userDuas

        let orderedUserDuas = userDuas.wrappedValue.sorted {
            $0.position < $1.position
        }
        _draftUserDuas = State(initialValue: orderedUserDuas)
        _savedUserDuas = State(initialValue: orderedUserDuas)
    }

    private var configurationKey: String {
        signature(userDuas)
    }

    private func signature(_ values: [UserDua]) -> String {
        values
            .map { "\($0.id.uuidString):\($0.repetitionCount):\($0.position)" }
            .joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            DuaConfigurationEditor(
                userDuas: $draftUserDuas,
                duas: MockData.duas,
                sectionTitle: "Dua Repetitions",
                baselineUserDuas: savedUserDuas,
                showsInlineEditButton: true,
                showsActionButtons: true,
                saveIsEnabled: $hasUnsavedChanges,
                onReset: resetDraft,
                onSave: saveConfiguration
            )
            .scrollContentBackground(.hidden)
            .background {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: draftUserDuas) { _, updated in
                hasUnsavedChanges = updated != savedUserDuas
            }
            .onChange(of: configurationKey) { _, _ in
                let current = userDuas.sorted { $0.position < $1.position }
                draftUserDuas = current
                savedUserDuas = current
                hasUnsavedChanges = false
            }
            .alert("Configuration Updated", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(confirmationMessage)
            }
        }
    }

    private func resetDraft() {
        draftUserDuas = savedUserDuas
        hasUnsavedChanges = false
        confirmationMessage = "Your changes were reset to the last saved settings."
        showingConfirmation = true
    }

    private func saveConfiguration() {
        guard hasUnsavedChanges else { return }

        for index in draftUserDuas.indices {
            draftUserDuas[index].position = index
        }

        savedUserDuas = draftUserDuas
        userDuas = draftUserDuas
        hasUnsavedChanges = false
        confirmationMessage = "Your settings have been saved."
        showingConfirmation = true
    }
}

#Preview("Settings") {
    @Previewable @State var previewUserDuas = MockData.userDuas
    let palette = AppPalette(date: .now)

    SettingsView(userDuas: $previewUserDuas)
        .environment(\.appPalette, palette)
        .environment(\.colorScheme, palette.isDaytime ? .light : .dark)
}
