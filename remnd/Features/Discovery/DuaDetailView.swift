import SwiftUI

struct DuaDetailView: View {
    let dua: Dua

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(dua.title)
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                detailSection(title: "Arabic") {
                    ArabicText(text: dua.arabic, size: 17)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                detailSection(title: "Meaning") {
                    Text(dua.translation)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                detailSection(title: "Benefit") {
                    Text(dua.benefit)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
        }
        .background(Color.remndScreenBackground.ignoresSafeArea())
        .navigationTitle("Dua Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.brandClrPrimary.opacity(0.35), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        DuaDetailView(dua: MockData.duas[0])
    }
}
