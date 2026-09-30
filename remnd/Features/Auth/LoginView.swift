import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @ObservedObject var session: LocalAppleSession
    var onPreview: (() -> Void)? = nil
    @State private var showingError = false
    #if DEBUG
    @AppStorage("remnd.debugPreviewNightTheme") private var previewNightTheme = false
    #endif

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let palette = palette(for: timeline.date)

            ZStack {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 38, weight: .light))
                            .foregroundStyle(palette.activeTab)
                            .frame(width: 92, height: 92)
                            .appGlassBackground(
                                palette.card,
                                in: RoundedRectangle(cornerRadius: 28),
                                palette: palette
                            )

                        Text("remnd")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.primaryText)

                        Text("A little remembrance, every day.")
                            .font(.title3)
                            .foregroundStyle(palette.primaryText)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.fullName]
                        } onCompletion: { result in
                            handle(result)
                        }
                        .signInWithAppleButtonStyle(palette.isDaytime ? .black : .white)
                        .frame(maxWidth: 375)
                        .frame(height: 56)
                        .accessibilityLabel("Continue with Apple")

                        #if DEBUG && targetEnvironment(simulator)
                        if let onPreview {
                            Button("Preview without signing in", action: onPreview)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.smallButtonIcon)
                                .frame(maxWidth: 375)
                                .frame(height: 50)
                                .appGlassBackground(
                                    palette.smallButton,
                                    in: Capsule(),
                                    palette: palette
                                )
                        }
                        #endif

                        Text("Your duas and progress stay on this device for now.")
                            .font(.caption)
                            .foregroundStyle(palette.hintText)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: 420)
                .padding(.horizontal, 28)
                .padding(.vertical, 36)
            }
            .environment(\.colorScheme, palette.isDaytime ? .light : .dark)
        }
        .alert("Couldn’t Sign In", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Apple couldn’t complete sign-in. Check your Apple Account and try again.")
        }
    }

    private func palette(for date: Date) -> AppPalette {
        #if DEBUG
        AppPalette(date: date, forceNight: previewNightTheme)
        #else
        AppPalette(date: date)
        #endif
    }

    private func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                showingError = true
                return
            }
            if !session.accept(credential) {
                showingError = true
            }

        case .failure(let error):
            if let authorizationError = error as? ASAuthorizationError,
               authorizationError.code == .canceled {
                return
            }
            showingError = true
        }
    }
}

#Preview {
    LoginView(session: LocalAppleSession(defaults: nil))
}
