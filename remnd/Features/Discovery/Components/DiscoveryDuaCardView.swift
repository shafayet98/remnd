import SwiftUI

struct DiscoveryDuaCardView: View {
    let dua: Dua
    let isAdded: Bool
    let onAdd: () -> Void

    private let cardShape = RoundedRectangle(cornerRadius: 24)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dua.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            sectionDivider

            ArabicText(text: dua.arabic, size: 17, lineLimit: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            sectionDivider

            Text(dua.translation)
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                NavigationLink {
                    DuaDetailView(dua: dua)
                } label: {
                    Label("Details", systemImage: "doc.text")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.duaBenefitTile, in: Capsule())
                }
                .buttonStyle(.plain)

                addButton
            }
            .padding(.top, 18)
        }
        .padding(20)
        .background(cardShape.fill(.white))
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(Color.brandClrPrimary, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(Color.brandClrPrimary.opacity(0.18))
            .padding(.vertical, 14)
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Label(
                isAdded ? "Added" : "Add",
                systemImage: isAdded ? "checkmark" : "plus"
            )
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isAdded ? Color.gray.opacity(0.12) : Color.duaCountTile,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .disabled(isAdded)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.remndScreenBackground
                .ignoresSafeArea()

            DiscoveryDuaCardView(
                dua: MockData.duas[0],
                isAdded: false,
                onAdd: {}
            )
            .padding(24)
        }
    }
}
