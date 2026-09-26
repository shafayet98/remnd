//
//  DuaCardView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//

import SwiftUI

struct DuaCardView: View {
    @Environment(\.appPalette) private var palette

    let dua: Dua
    let countLeft: Int

    private enum InfoSection: Hashable {
        case benefit
        case meaning
    }

    @State private var isShowingBenefit = false
    @State private var selectedInfoSection: InfoSection = .benefit

    private let cardShape = RoundedRectangle(cornerRadius: 28)

    var body: some View {
        ZStack {
            frontFace
                .opacity(isShowingBenefit ? 0 : 1)
                .allowsHitTesting(!isShowingBenefit)

            benefitFace
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isShowingBenefit ? 1 : 0)
                .allowsHitTesting(isShowingBenefit)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(cardShape.fill(palette.card))
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(palette.cardBorder, lineWidth: 1.25)
        }
        .shadow(
            color: .black.opacity(0.08),
            radius: 14,
            y: 6
        )
        .rotation3DEffect(
            .degrees(isShowingBenefit ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.7
        )
    }

    private var frontFace: some View {
        GeometryReader { geometry in
            let topPadding: CGFloat = 16
            let footerHeight: CGFloat = 40
            let interItemSpacing: CGFloat = 40
            let controlsHeight: CGFloat = 56
            let tileHeight = max(
                0,
                (geometry.size.height - topPadding - footerHeight - interItemSpacing - controlsHeight) / 2
            )

            VStack(spacing: 16) {
                scrollableTile(background: palette.arabicTile) {
                    ArabicText(text: dua.arabic, size: 17)
                }
                .frame(height: tileHeight)

                scrollableTile(background: palette.transliterationTile) {
                    Text(dua.transliteration ?? "")
                        .font(.system(size: 17))
                        .foregroundStyle(palette.transliterationText)
                        .lineSpacing(2.5)
                }
                .frame(height: tileHeight)

                HStack(spacing: 10) {
                    infoButton(
                        systemImage: "book.closed",
                        background: palette.smallButton,
                        accessibilityLabel: "Show benefit"
                    ) {
                        showInfoSection(.benefit)
                    }

                    Text(countLeft, format: .number)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(palette.counterText)
                        .frame(width: 56, height: 56)
                        .background(palette.counter, in: Capsule())
                        .accessibilityLabel("\(countLeft) repetitions remaining")

                    infoButton(
                        systemImage: "text.quote",
                        background: palette.smallButton,
                        accessibilityLabel: "Show meaning"
                    ) {
                        showInfoSection(.meaning)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: controlsHeight)
            }
            .padding(.horizontal, 16)
            .padding(.top, topPadding)
            .padding(.bottom, footerHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .bottom) {
                Label("Swipe right to complete", systemImage: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(palette.hintText)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .padding(.bottom, 8)
            }
        }
    }

    private var benefitFace: some View {
        VStack(spacing: 16) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        detailPanel(
                            title: "Benefit",
                            systemImage: "book.closed",
                            text: dua.benefit,
                            background: palette.smallButton
                        )
                        .id(InfoSection.benefit)

                        detailPanel(
                            title: "Meaning",
                            systemImage: "text.quote",
                            text: dua.translation,
                            background: palette.meaningTile
                        )
                        .id(InfoSection.meaning)
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: isShowingBenefit) { _, showingBenefit in
                    guard showingBenefit else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(selectedInfoSection, anchor: .top)
                    }
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isShowingBenefit = false
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title3.weight(.medium))
                    .frame(width: 56, height: 56)
                    .background(palette.smallButton, in: Capsule())
                    .foregroundStyle(palette.smallButtonIcon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Flip back to dua")
        }
        .padding(24)
    }

    private func infoButton(
        systemImage: String,
        background: Color,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.smallButtonIcon)
                .frame(width: 56, height: 56)
                .background(background, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func showInfoSection(_ section: InfoSection) {
        selectedInfoSection = section
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingBenefit = true
        }
    }

    private func detailPanel(
        title: String,
        systemImage: String,
        text: String,
        background: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(palette.primaryText)

            Text(text)
                .font(.body)
                .foregroundStyle(palette.meaningText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(background, in: RoundedRectangle(cornerRadius: 24))
    }

    private func scrollableTile<Content: View>(
        background: Color,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                content()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(minHeight: geometry.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(AppPalette(date: .now).background)
            .ignoresSafeArea()

        DuaCardView(
            dua: MockData.duas[0],
            countLeft: 33
        )
        .padding(24)
    }
}
