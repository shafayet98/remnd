//
//  MyDuasView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//



import SwiftUI

struct MyDuasView: View {

    // MARK: - State

    @State private var cards = DeckBuilder.build(
        userDuas: MockData.userDuas,
        duas: MockData.duas
    )

    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingSwipe = false

    // MARK: - Properties

    private let totalCards = DeckBuilder.build(
        userDuas: MockData.userDuas,
        duas: MockData.duas
    ).count

    private let swipeThreshold: CGFloat = 110

    private var visibleCards: [DuaCardItem] {
        Array(cards.prefix(3))
    }

    private var completedCount: Int {
        totalCards - cards.count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                progressHeader

                Spacer()

                cardStack
                    .frame(height: 420)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxWidth: .infinity)
            .background(
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("My Duas")
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        HStack {
            Text("Today's Progress")
                .font(.headline)

            Spacer()

            Text("\(completedCount) / \(totalCards)")
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        GeometryReader { geometry in

            ZStack {

                if cards.isEmpty {

                    completionView

                } else {

                    ForEach(
                        Array(visibleCards.reversed())
                    ) { card in

                        stackedCard(
                            card,
                            depth: depth(for: card),
                            exitDistance: geometry.size.width + 400
                        )
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }

    // MARK: - Card Depth

    private func depth(
        for card: DuaCardItem
    ) -> Int {

        visibleCards.firstIndex {
            $0.id == card.id
        } ?? 0
    }

    // MARK: - Individual Stacked Card

    private func stackedCard(
        _ card: DuaCardItem,
        depth: Int,
        exitDistance: CGFloat
    ) -> some View {

        let isTopCard = depth == 0

        let scale = 1 - CGFloat(depth) * 0.04
        let verticalOffset = CGFloat(depth) * 14

        let xOffset: CGFloat = isTopCard
            ? dragOffset.width
            : 0

        let yOffset: CGFloat = verticalOffset +
            (isTopCard ? dragOffset.height : 0)

        let rotation: Double = isTopCard
            ? Double(dragOffset.width / 25)
            : 0

        return DuaCardView(dua: card.dua)
            .scaleEffect(scale)
            .offset(
                x: xOffset,
                y: yOffset
            )
            .rotationEffect(
                .degrees(rotation)
            )
            .zIndex(Double(3 - depth))
            .gesture(
                swipeGesture(
                    for: card.id,
                    exitDistance: exitDistance
                )
            )
            .allowsHitTesting(isTopCard)
    }

    // MARK: - Swipe Gesture

    private func swipeGesture(
        for cardID: String,
        exitDistance: CGFloat
    ) -> some Gesture {

        DragGesture(minimumDistance: 10)

            .onChanged { value in

                guard !isAnimatingSwipe,
                      cards.first?.id == cardID
                else {
                    return
                }

                let horizontal = value.translation.width
                let vertical = value.translation.height

                guard horizontal > 0,
                      horizontal > abs(vertical)
                else {
                    return
                }

                dragOffset = CGSize(
                    width: horizontal,
                    height: vertical * 0.15
                )
            }

            .onEnded { value in

                guard !isAnimatingSwipe,
                      cards.first?.id == cardID
                else {
                    return
                }

                let horizontal = value.translation.width
                let vertical = value.translation.height

                if horizontal > swipeThreshold &&
                    horizontal > abs(vertical) {

                    completeTopCard(
                        exitDistance: exitDistance,
                        verticalDrag: vertical
                    )

                } else {

                    withAnimation(
                        .spring(
                            response: 0.35,
                            dampingFraction: 0.7
                        )
                    ) {
                        dragOffset = .zero
                    }
                }
            }
    }

    // MARK: - Complete Card

    private func completeTopCard(
        exitDistance: CGFloat,
        verticalDrag: CGFloat
    ) {

        guard !cards.isEmpty,
              !isAnimatingSwipe
        else {
            return
        }

        isAnimatingSwipe = true

        withAnimation(
            .easeOut(duration: 0.25)
        ) {
            dragOffset = CGSize(
                width: exitDistance,
                height: verticalDrag * 0.2
            )

        } completion: {

            withAnimation(
                .spring(
                    response: 0.38,
                    dampingFraction: 0.82
                )
            ) {
                cards.removeFirst()
                dragOffset = .zero

            } completion: {
                isAnimatingSwipe = false
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {

        VStack(spacing: 16) {

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Today's Duas Completed")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(totalCards) / \(totalCards)")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MyDuasView()
}
