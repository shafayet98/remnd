//
//  MyDuasView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//



import SwiftUI


struct MyDuasView: View {

    @Environment(\.appPalette) private var palette
    @ObservedObject var store: AppDataStore

    // MARK: - State

    // Swipe state
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingSwipe = false
    @State private var isShowingTopCardDetails = false

    // Configuration state
    @State private var showingConfigure = false

    // MARK: - Constants

    private let swipeThreshold: CGFloat = 110

    // MARK: - Computed Properties

    private var cards: [DuaCardItem] { store.remainingCards }

    private var totalCards: Int { store.totalCards }

    private var visibleCards: [DuaCardItem] {
        Array(cards.prefix(3))
    }

    private var completedCount: Int {
        totalCards - cards.count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if store.hasPendingConfiguration {
                    pendingConfigurationMessage
                }
                cardStack
                    .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()
            )
            .onChange(of: cards.first?.id) { _, _ in
                isShowingTopCardDetails = false
            }

            // Configuration sheet
            .sheet(
                isPresented: $showingConfigure
            ) {
                ConfigureMyDuasView(
                    userDuas: store.userDuas,
                    duas: store.allDuas,
                    onSave: store.setUserDuas
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Pending Configuration Message

    private var pendingConfigurationMessage: some View {
        Label(
            "Configuration saved for your next session.",
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        GeometryReader { geometry in

            ZStack {

                if cards.isEmpty {

                    if totalCards > 0 {
                        completionView
                    } else {
                        emptyDeckView
                    }

                } else {

                    ForEach(
                        Array(visibleCards.reversed())
                    ) { card in

                        stackedCard(
                            card,
                            depth: depth(for: card),
                            exitDistance:
                                geometry.size.width + 400
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

        // Stack appearance
        let scale: CGFloat =
            1 - CGFloat(depth) * 0.04

        let verticalOffset: CGFloat =
            CGFloat(depth) * 14

        // Swipe movement
        let xOffset: CGFloat = isTopCard
            ? dragOffset.width
            : 0

        let yOffset: CGFloat =
            verticalOffset +
            (isTopCard ? dragOffset.height : 0)

        let rotation: Double = isTopCard
            ? Double(dragOffset.width / 25)
            : 0

        let countLeft = cards.reduce(into: 0) { count, remainingCard in
            if remainingCard.userDuaID == card.userDuaID {
                count += 1
            }
        }

        return DuaCardView(
            dua: card.dua,
            countLeft: countLeft,
            onFlipChange: isTopCard ? { isShowingTopCardDetails = $0 } : nil
        )
        .opacity(isTopCard || !isShowingTopCardDetails ? 1 : 0)
        .animation(.easeOut(duration: 0.16), value: isShowingTopCardDetails)
        .scaleEffect(scale)
        .offset(
            x: xOffset,
            y: yOffset
        )
        .rotationEffect(
            .degrees(rotation)
        )
        .zIndex(
            Double(3 - depth)
        )
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

        DragGesture(
            minimumDistance: 10
        )

        .onChanged { value in

            guard
                !isAnimatingSwipe,
                cards.first?.id == cardID
            else {
                return
            }

            let horizontal =
                value.translation.width

            let vertical =
                value.translation.height

            // Track rightward movement immediately so a diagonal drag
            // doesn't cause the card to jump once it becomes horizontal.
            guard horizontal > 0 else {
                dragOffset = .zero
                return
            }

            dragOffset = CGSize(
                width: horizontal,
                height: vertical * 0.15
            )
        }

        .onEnded { value in

            guard
                !isAnimatingSwipe,
                cards.first?.id == cardID
            else {
                return
            }

            let horizontal =
                value.translation.width

            let vertical =
                value.translation.height

            if horizontal > swipeThreshold &&
                horizontal > abs(vertical) {

                // Successful swipe
                completeTopCard(
                    exitDistance: exitDistance,
                    verticalDrag: vertical
                )

            } else {

                // Unsuccessful swipe
                // Return to original position
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

    // MARK: - Complete Top Card

    private func completeTopCard(
        exitDistance: CGFloat,
        verticalDrag: CGFloat
    ) {

        guard
            !cards.isEmpty,
            !isAnimatingSwipe
        else {
            return
        }

        isAnimatingSwipe = true
        let completedAt = Date()

        // Animate current card offscreen
        withAnimation(
            .easeOut(duration: 0.25)
        ) {

            dragOffset = CGSize(
                width: exitDistance,
                height: verticalDrag * 0.2
            )

        } completion: {

            // Remove completed card
            // and reveal the next card
            withAnimation(
                .spring(
                    response: 0.38,
                    dampingFraction: 0.82
                )
            ) {

                store.completeCard(at: completedAt)
                dragOffset = .zero

            } completion: {

                isAnimatingSwipe = false
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {

        VStack(spacing: 16) {

            Image(
                systemName: "checkmark.circle.fill"
            )
            .font(
                .system(size: 64)
            )
            .foregroundStyle(palette.activeTab)

            Text(
                "Today's Duas Completed"
            )
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(palette.primaryText)

            Text(
                "\(totalCards) / \(totalCards)"
            )
            .foregroundStyle(palette.inactiveTab)
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // MARK: - Empty Deck View

    private var emptyDeckView: some View {

        VStack(spacing: 16) {

            Image(
                systemName: "square.stack"
            )
            .font(
                .system(size: 54)
            )
            .foregroundStyle(palette.inactiveTab)

            Text("No Duas Added")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(palette.primaryText)

            Text(
                "Add some duas to create your daily routine."
            )
            .font(.subheadline)
            .foregroundStyle(palette.inactiveTab)
            .multilineTextAlignment(.center)

            Button("Configure My Duas") {
                showingConfigure = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(
            maxWidth: .infinity
        )
    }
}

// MARK: - Preview

#Preview {
    MyDuasView(store: AppDataStore(defaults: nil))
}
