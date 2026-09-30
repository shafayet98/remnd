import SwiftUI

struct ConfigureMyDuasView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appPalette) private var palette

    @State private var draftUserDuas: [UserDua]
    private let savedUserDuas: [UserDua]

    let duas: [Dua]
    let onSave: ([UserDua]) -> Void

    private var hasUnsavedChanges: Bool {
        signature(draftUserDuas) != signature(savedUserDuas)
    }

    init(
        userDuas: [UserDua],
        duas: [Dua],
        onSave: @escaping ([UserDua]) -> Void
    ) {
        self.duas = duas
        self.onSave = onSave

        let orderedUserDuas = userDuas.sorted { $0.position < $1.position }
        self.savedUserDuas = orderedUserDuas
        _draftUserDuas = State(initialValue: orderedUserDuas)
    }

    var body: some View {
        NavigationStack {
            DuaConfigurationEditor(
                userDuas: $draftUserDuas,
                duas: duas,
                sectionTitle: "Your Duas",
                baselineUserDuas: savedUserDuas
            )
            .scrollContentBackground(.hidden)
            .background {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()
            }
            .navigationTitle("Configure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset", action: resetDraft)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: saveConfiguration)
                        .fontWeight(.semibold)
                        .disabled(!hasUnsavedChanges)
                }

                ToolbarItem(placement: .bottomBar) {
                    EditButton()
                }
            }
        }
    }

    private func resetDraft() {
        draftUserDuas = savedUserDuas
    }

    private func signature(_ values: [UserDua]) -> String {
        values
            .map { "\($0.id.uuidString):\($0.repetitionCount):\($0.position)" }
            .joined(separator: "|")
    }

    private func saveConfiguration() {
        for index in draftUserDuas.indices {
            draftUserDuas[index].position = index
        }

        onSave(draftUserDuas)
        dismiss()
    }
}

#Preview {
    ConfigureMyDuasView(
        userDuas: MockData.userDuas,
        duas: MockData.duas
    ) { updatedDuas in
        print("Saved configuration:", updatedDuas)
    }
}
