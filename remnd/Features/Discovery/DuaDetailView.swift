import SwiftUI

struct DuaDetailView: View {
    @Environment(\.appPalette) private var palette
    let dua: Dua

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(dua.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(palette.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                detailSection(title: "Arabic") {
                    ArabicText(text: dua.arabic, size: 17)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                detailSection(title: "Meaning") {
                    Text(dua.translation)
                        .font(.body)
                        .foregroundStyle(palette.meaningText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                detailSection(title: "Benefit") {
                    Text(dua.benefit)
                        .font(.body)
                        .foregroundStyle(palette.meaningText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
        }
        .background {
            Rectangle()
                .fill(palette.background)
                .ignoresSafeArea()
        }
        .navigationTitle("Dua Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(palette.navigationBar, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(palette.isDaytime ? .light : .dark, for: .navigationBar)
    }

    private func detailSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(palette.primaryText)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(palette.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        DuaDetailView(dua: MockData.duas[0])
    }
}
