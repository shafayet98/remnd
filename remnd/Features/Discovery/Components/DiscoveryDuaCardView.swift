import SwiftUI

struct DiscoveryDuaCardView: View {
    @Environment(\.appPalette) private var palette

    let dua: Dua
    let isAdded: Bool
    let onAdd: () -> Void

    private let cardShape = RoundedRectangle(cornerRadius: 24)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dua.title)
                .font(.headline)
                .foregroundStyle(palette.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            sectionDivider

            ArabicText(text: dua.arabic, size: 17, lineLimit: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            sectionDivider

            Text(dua.translation)
                .font(.system(size: 17))
                .foregroundStyle(palette.meaningText)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                NavigationLink {
                    DuaDetailView(dua: dua)
                } label: {
                    Label("Details", systemImage: "doc.text")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.smallButtonIcon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .appGlassBackground(palette.smallButton, in: Capsule(), palette: palette)
                }
                .buttonStyle(.plain)

                addButton
            }
            .padding(.top, 18)
        }
        .padding(20)
        .appGlassBackground(palette.card, in: cardShape, palette: palette)
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(palette.cardBorder.opacity(0.7))
            .padding(.vertical, 14)
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Label(
                isAdded ? "Added" : "Add",
                systemImage: isAdded ? "checkmark" : "plus"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isAdded ? palette.inactiveTab : palette.counterText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .appGlassBackground(
                isAdded ? palette.smallButton : palette.counter,
                in: Capsule(),
                palette: palette
            )
        }
        .buttonStyle(.plain)
        .disabled(isAdded)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Rectangle()
                .fill(AppPalette(date: .now).background)
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
