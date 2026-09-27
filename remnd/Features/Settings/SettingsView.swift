import SwiftUI

struct SettingsView: View {
    @Environment(\.appPalette) private var palette
    @Binding private var userDuas: [UserDua]
    let duas: [Dua]

    @State private var draftUserDuas: [UserDua]
    @State private var savedUserDuas: [UserDua]
    @State private var hasUnsavedChanges = false
    @State private var showingConfirmation = false

    init(userDuas: Binding<[UserDua]>, duas: [Dua] = MockData.duas) {
        self._userDuas = userDuas
        self.duas = duas

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
                duas: duas,
                sectionTitle: "Dua Repetitions",
                baselineUserDuas: savedUserDuas,
                showsInlineEditButton: true,
                showsActionButtons: true,
                saveIsEnabled: $hasUnsavedChanges,
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
            .alert("Settings Saved", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your settings have been saved.")
            }
        }
    }

    private func saveConfiguration() {
        guard hasUnsavedChanges else { return }

        for index in draftUserDuas.indices {
            draftUserDuas[index].position = index
        }

        savedUserDuas = draftUserDuas
        userDuas = draftUserDuas
        hasUnsavedChanges = false
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
