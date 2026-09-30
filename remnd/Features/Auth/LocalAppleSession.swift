import AuthenticationServices
import Combine
import Foundation

@MainActor
final class LocalAppleSession: ObservableObject {
    enum State: Equatable {
        case checking
        case signedOut
        case signedIn(String)
    }

    @Published private(set) var state: State
    @Published private(set) var displayName: String?

    private let defaults: UserDefaults?
    private let userIDKey = "remnd.localAppleUserID"

    init(defaults: UserDefaults? = .standard) {
        self.defaults = defaults
        if let userID = defaults?.string(forKey: userIDKey) {
            state = .checking
            displayName = defaults?.string(forKey: Self.nameKey(for: userID))
        } else {
            state = .signedOut
            displayName = nil
        }
    }

    func restoreIfNeeded() async {
        guard state == .checking else { return }
        guard let userID = defaults?.string(forKey: userIDKey) else {
            state = .signedOut
            return
        }
        await checkCredential(for: userID, isRestoring: true)
    }

    func recheckIfSignedIn() async {
        guard case .signedIn(let userID) = state else { return }
        await checkCredential(for: userID, isRestoring: false)
    }

    @discardableResult
    func accept(_ credential: ASAuthorizationAppleIDCredential) -> Bool {
        let userID = credential.user
        guard !userID.isEmpty else { return false }

        if let name = credential.fullName?.formatted().trimmingCharacters(in: .whitespacesAndNewlines),
           !name.isEmpty {
            defaults?.set(name, forKey: Self.nameKey(for: userID))
            displayName = name
        } else {
            displayName = defaults?.string(forKey: Self.nameKey(for: userID))
        }

        defaults?.set(userID, forKey: userIDKey)
        state = .signedIn(userID)
        return true
    }

    func signOut() {
        defaults?.removeObject(forKey: userIDKey)
        displayName = nil
        state = .signedOut
    }

    private func checkCredential(for userID: String, isRestoring: Bool) async {
        do {
            let credentialState = try await ASAuthorizationAppleIDProvider()
                .credentialState(forUserID: userID)
            switch credentialState {
            case .authorized:
                state = .signedIn(userID)
            case .revoked, .notFound, .transferred:
                signOut()
            @unknown default:
                signOut()
            }
        } catch {
            // Keep an existing local session through a temporary state-check failure.
            if isRestoring { state = .signedOut }
        }
    }

    private static func nameKey(for userID: String) -> String {
        "remnd.localAppleName.\(userID)"
    }
}
