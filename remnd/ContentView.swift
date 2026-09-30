//
//  ContentView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 19/9/2026.
//

import AuthenticationServices
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = LocalAppleSession()
    @State private var isPreviewing = false

    var body: some View {
        Group {
            if isPreviewing {
                RootTabView(onSignOut: { isPreviewing = false }, signOutTitle: "Leave Preview")
            } else {
                switch session.state {
                case .checking:
                    ZStack {
                        Rectangle()
                            .fill(AppPalette(date: .now).background)
                            .ignoresSafeArea()

                        ProgressView("Checking Apple sign-in…")
                            .tint(AppPalette(date: .now).activeTab)
                            .foregroundStyle(AppPalette(date: .now).primaryText)
                    }

                case .signedOut:
                    LoginView(session: session, onPreview: { isPreviewing = true })

                case .signedIn(let userID):
                    RootTabView(
                        appleUserID: userID,
                        suggestedUsername: session.displayName,
                        onSignOut: session.signOut
                    )
                    .id(userID)
                }
            }
        }
        .task { await session.restoreIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await session.recheckIfSignedIn() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: ASAuthorizationAppleIDProvider.credentialRevokedNotification
        )) { _ in
            session.signOut()
        }
    }
}

#Preview {
    ContentView()
}
