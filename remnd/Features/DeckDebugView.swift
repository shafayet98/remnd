//
//  DeckDebugView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//


import SwiftUI

struct DeckDebugView: View {

    private let deck = DeckBuilder.build(
        userDuas: MockData.userDuas,
        duas: MockData.duas
    )

    var body: some View {

        NavigationStack {
            List {
                Section {
                    Text("Total Cards: \(deck.count)")
                        .font(.headline)
                }

                Section("Generated Cards") {
                    ForEach(deck) { card in

                        HStack {
                            Text(card.dua.title)

                            Spacer()

                            Text(
                                "#\(card.repetitionIndex)"
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Deck Test")
        }
    }
}

#Preview {
    DeckDebugView()
}
