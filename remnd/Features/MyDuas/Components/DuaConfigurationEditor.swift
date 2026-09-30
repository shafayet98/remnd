import SwiftUI

struct DuaConfigurationEditor: View {
    @Environment(\.appPalette) private var palette
    #if DEBUG
    @AppStorage("remnd.debugPreviewNightTheme") private var previewNightTheme = false
    #endif
    @Binding var userDuas: [UserDua]

    let duas: [Dua]
    let sectionTitle: String
    let baselineUserDuas: [UserDua]
    var showsInlineEditButton = false
    var showsActionButtons = false
    var saveIsEnabled: Binding<Bool>?
    var onSave: (() -> Void)?

    private var totalCards: Int {
        userDuas.reduce(0) { $0 + $1.repetitionCount }
    }

    private var hasUnsavedChanges: Bool {
        saveIsEnabled?.wrappedValue
            ?? (configurationSignature(userDuas) != configurationSignature(baselineUserDuas))
    }

    var body: some View {
        List {
            Section {
                ForEach($userDuas) { $userDua in
                    HStack(spacing: 12) {
                        Text(title(for: userDua.duaID))
                            .font(.body)
                            .foregroundStyle(palette.isDaytime ? Color.primary : palette.primaryText)

                        Spacer()

                        Stepper(
                            value: Binding(
                                get: { userDua.repetitionCount },
                                set: { newValue in
                                    userDua.repetitionCount = newValue
                                    updateSaveAvailability()
                                }
                            ),
                            in: 1...100
                        ) {
                            Text("×\(userDua.repetitionCount)")
                                .monospacedDigit()
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    .padding(.vertical, 12)
                    .listRowBackground(palette.card)
                }
                .onMove(perform: moveDua)
                .onDelete(perform: deleteDua)
            } header: {
                HStack {
                    Text(sectionTitle)
                    Spacer()
                    if showsInlineEditButton {
                        EditButton()
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.activeTab)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .appGlassBackground(palette.smallButton, in: Capsule(), palette: palette)
                            .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 14)
            } footer: {
                if !showsActionButtons {
                    Text("Set the number of times you want to recite each dua.")
                }
            }

            Section {
                if showsActionButtons {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set the number of times you want to recite each dua.")
                            .font(.footnote)
                            .foregroundStyle(palette.hintText)
                            .padding(.horizontal, 12)

                        totalCardsRow

                        saveButton
                    }
                    .padding(.vertical, 10)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    totalCardsRow
                }
            }

            #if DEBUG
            if showsActionButtons {
                Section {
                    Toggle("Preview night theme", isOn: $previewNightTheme)
                        .foregroundStyle(palette.primaryText)
                        .tint(palette.activeTab)
                        .listRowBackground(palette.card)
                } header: {
                    Text("Appearance Preview")
                } footer: {
                    Text("Turn this off to follow your local time again.")
                }
            }
            #endif
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(0)
        .tint(palette.activeTab)
    }

    private func title(for duaID: String) -> String {
        duas.first { $0.id == duaID }?.title ?? "Unknown Dua"
    }

    private func moveDua(from source: IndexSet, to destination: Int) {
        userDuas.move(fromOffsets: source, toOffset: destination)
        updateSaveAvailability()
    }

    private func deleteDua(at offsets: IndexSet) {
        userDuas.remove(atOffsets: offsets)
        updateSaveAvailability()
    }

    private func updateSaveAvailability() {
        saveIsEnabled?.wrappedValue =
            configurationSignature(userDuas) != configurationSignature(baselineUserDuas)
    }

    private var totalCardsRow: some View {
        HStack {
            Text("Total Daily Cards")
            Spacer()
            Text("\(totalCards)")
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .appGlassBackground(palette.card, in: Capsule(), palette: palette)
    }

    private func configurationSignature(_ values: [UserDua]) -> String {
        values
            .map { "\($0.id.uuidString):\($0.repetitionCount):\($0.position)" }
            .joined(separator: "|")
    }

    private var saveButton: some View {
        Button {
            onSave?()
        } label: {
            Text("Save")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 62)
                .foregroundStyle(hasUnsavedChanges ? palette.counterText : Color.gray)
                .background(
                    hasUnsavedChanges ? palette.activeTab : Color.gray.opacity(0.24),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .disabled(!hasUnsavedChanges || onSave == nil)
    }
}
#Preview("Dua Repetitions") {
    @Previewable @State var previewUserDuas = MockData.userDuas
    let palette = AppPalette(date: .now)

    SettingsView(userDuas: $previewUserDuas)
        .environment(\.appPalette, palette)
        .environment(\.colorScheme, palette.isDaytime ? .light : .dark)
}
