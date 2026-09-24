//
//  ConfigureMyDuasView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//


import SwiftUI

struct ConfigureMyDuasView: View {

    @Environment(\.dismiss) private var dismiss

    // Editable copy of the user's configuration
    @State private var draftUserDuas: [UserDua]

    let duas: [Dua]
    let onSave: ([UserDua]) -> Void

    // MARK: - Initializer

    init(
        userDuas: [UserDua],
        duas: [Dua],
        onSave: @escaping ([UserDua]) -> Void
    ) {
        self.duas = duas
        self.onSave = onSave

        _draftUserDuas = State(
            initialValue: userDuas.sorted {
                $0.position < $1.position
            }
        )
    }

    // MARK: - Properties

    private var totalCards: Int {
        draftUserDuas.reduce(0) {
            $0 + $1.repetitionCount
        }
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            List {

                Section {
                    ForEach($draftUserDuas) { $userDua in

                        HStack(spacing: 12) {

                            Text(
                                title(for: userDua.duaID)
                            )
                            .font(.body)

                            Spacer()

                            Stepper(
                                value: $userDua.repetitionCount,
                                in: 1...100
                            ) {
                                Text(
                                    "×\(userDua.repetitionCount)"
                                )
                                .monospacedDigit()
                            }
                            .fixedSize(
                                horizontal: true,
                                vertical: false
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .onMove(perform: moveDua)
                    .onDelete(perform: deleteDua)

                } header: {
                    Text("Your Duas")
                } footer: {
                    Text(
                        "Set the number of times you want " +
                        "to recite each dua."
                    )
                }

                Section {
                    HStack {

                        Text("Total Daily Cards")

                        Spacer()

                        Text("\(totalCards)")
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Configure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Done") {
                        saveConfiguration()
                    }
                    .fontWeight(.semibold)
                }

                ToolbarItem(
                    placement: .bottomBar
                ) {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Helpers

    private func title(
        for duaID: String
    ) -> String {

        duas.first {
            $0.id == duaID
        }?.title ?? "Unknown Dua"
    }

    // MARK: - Reordering

    private func moveDua(
        from source: IndexSet,
        to destination: Int
    ) {

        draftUserDuas.move(
            fromOffsets: source,
            toOffset: destination
        )
    }

    // MARK: - Delete

    private func deleteDua(
        at offsets: IndexSet
    ) {

        draftUserDuas.remove(
            atOffsets: offsets
        )
    }

    // MARK: - Save

    private func saveConfiguration() {

        // Update positions to match
        // the new order.

        for index in draftUserDuas.indices {
            draftUserDuas[index].position = index
        }

        onSave(draftUserDuas)

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ConfigureMyDuasView(
        userDuas: MockData.userDuas,
        duas: MockData.duas
    ) { updatedDuas in

        print(
            "Saved configuration:",
            updatedDuas
        )
    }
}
