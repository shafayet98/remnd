import SwiftUI

struct DiscoveryView: View {
    @Environment(\.appPalette) private var palette
    @Binding var userDuas: [UserDua]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(MockData.duas) { dua in
                        DiscoveryDuaCardView(
                            dua: dua,
                            isAdded: isAdded(dua),
                            onAdd: { add(dua) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func isAdded(_ dua: Dua) -> Bool {
        userDuas.contains { $0.duaID == dua.id }
    }

    private func add(_ dua: Dua) {
        guard !isAdded(dua) else { return }

        let nextPosition = (userDuas.map(\.position).max() ?? -1) + 1
        userDuas.append(
            UserDua(
                id: UUID(),
                duaID: dua.id,
                repetitionCount: 1,
                position: nextPosition
            )
        )
    }
}

#Preview {
    DiscoveryView(userDuas: .constant(MockData.userDuas))
}
