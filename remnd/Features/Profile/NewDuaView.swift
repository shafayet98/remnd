import SwiftUI

struct NewDuaView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AppDataStore

    @State private var title = ""
    @State private var arabic = ""
    @State private var transliteration = ""
    @State private var meaning = ""
    @State private var benefit = ""
    @State private var confirmationTitle = ""
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var didSubmit = false

    private var canSubmit: Bool {
        !trimmed(title).isEmpty && !trimmed(arabic).isEmpty &&
        !trimmed(meaning).isEmpty && !trimmed(benefit).isEmpty && !didSubmit
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Add new supplication")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.primaryText)

                Text("Add it to your own deck now, or save it as a submission for public review.")
                    .font(.subheadline)
                    .foregroundStyle(palette.hintText)

                field("Title") {
                    TextField("Dua title", text: $title)
                        .textInputAutocapitalization(.words)
                }

                field("Arabic") {
                    TextEditor(text: $arabic)
                        .font(.system(size: 17))
                        .multilineTextAlignment(.trailing)
                        .frame(minHeight: 110)
                }

                field("Transliteration (optional)") {
                    TextEditor(text: $transliteration)
                        .frame(minHeight: 85)
                }

                field("Meaning") {
                    TextEditor(text: $meaning)
                        .frame(minHeight: 100)
                }

                field("Benefit") {
                    TextEditor(text: $benefit)
                        .frame(minHeight: 100)
                }

                Button { submit(personal: true) } label: {
                    Label("Add to My Duas", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .foregroundStyle(palette.counterText)
                .background(palette.activeTab, in: Capsule())
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.5)

                Button { submit(personal: false) } label: {
                    Label("Publish for All", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .foregroundStyle(palette.smallButtonIcon)
                .appGlassBackground(palette.smallButton, in: Capsule(), palette: palette)
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.5)

                Text("Public submissions stay pending until they are reviewed and approved.")
                    .font(.caption)
                    .foregroundStyle(palette.hintText)
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background {
            Rectangle()
                .fill(palette.background)
                .ignoresSafeArea()
        }
        .navigationTitle("New Dua")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(palette.navigationBar, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(palette.activeTab)
        .alert(confirmationTitle, isPresented: $showingConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text(confirmationMessage)
        }
    }

    private func field<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.primaryText)
            content()
                .foregroundStyle(palette.primaryText)
                .padding(10)
                .appGlassBackground(
                    palette.smallButton.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 12),
                    palette: palette
                )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassBackground(
            palette.card,
            in: RoundedRectangle(cornerRadius: 20),
            palette: palette
        )
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit(personal: Bool) {
        guard canSubmit else { return }
        let trimmedTransliteration = trimmed(transliteration)
        let dua = Dua(
            id: UUID().uuidString,
            title: trimmed(title),
            arabic: trimmed(arabic),
            transliteration: trimmedTransliteration.isEmpty ? nil : trimmedTransliteration,
            translation: trimmed(meaning),
            benefit: trimmed(benefit)
        )

        if personal {
            store.addPersonalDua(dua)
            confirmationTitle = "Added to My Duas"
            confirmationMessage = "Your dua is in your personal list. If today's deck has started, it will appear in the next daily deck."
        } else {
            store.submitForReview(dua)
            confirmationTitle = "Pending Review"
            confirmationMessage = "Your submission is saved as pending review on this device. It will not appear in Discovery until approved."
        }
        didSubmit = true
        showingConfirmation = true
    }
}

#Preview {
    NavigationStack {
        NewDuaView(store: AppDataStore(defaults: nil))
    }
}
