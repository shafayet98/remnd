//
//  DuaCardView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//


import SwiftUI

struct DuaCardView: View {
    let dua: Dua

    var body: some View {
        VStack(spacing: 24) {

            // Title
            Text(dua.title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            // Arabic
            Text(dua.arabic)
                .font(.system(size: 38))
                .multilineTextAlignment(.center)
                .environment(
                    \.layoutDirection,
                    .rightToLeft
                )

            // Transliteration
            if let transliteration = dua.transliteration {
                Text(transliteration)
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }

            // Translation
            Text(dua.translation)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 8)

            // Gesture hint
            Label(
                "Swipe right to complete",
                systemImage: "arrow.right"
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .frame(height: 380)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(
                    Color.primary.opacity(0.06),
                    lineWidth: 1
                )
        }
        .shadow(
            color: .black.opacity(0.08),
            radius: 14,
            y: 6
        )
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()

        DuaCardView(
            dua: MockData.duas[0]
        )
        .padding(24)
    }
}
