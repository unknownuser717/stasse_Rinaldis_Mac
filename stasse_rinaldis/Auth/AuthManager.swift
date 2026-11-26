import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// Gère l'authentification Firebase : email / mot de passe et Google.
/// (Sign in with Apple n'est pas inclus : il exige l'Apple Developer Program payant.)
@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var user: User?
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published private(set) var isLoading = false

    /// `false` si GoogleService-Info.plist n'a pas encore été ajouté au projet.
    let isFirebaseConfigured: Bool

    /// Les tests UI (argument `-ui-testing`) contournent l'écran de connexion.
    private let bypassForUITests: Bool
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    var isAuthenticated: Bool { bypassForUITests || user != nil }

    init(isFirebaseConfigured: Bool, bypassForUITests: Bool = false) {
        self.isFirebaseConfigured = isFirebaseConfigured
        self.bypassForUITests = bypassForUITests

        guard isFirebaseConfigured else { return }

        user = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    // MARK: - Email / mot de passe

    func signUp(email: String, password: String) async {
        await perform {
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
    }

    func signIn(email: String, password: String) async {
        await perform {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }

    func resetPassword(email: String) async {
        await perform {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        }
        if errorMessage == nil {
            infoMessage = "Un email de réinitialisation a été envoyé à \(email)."
        }
    }

    // MARK: - Google

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Client ID Google introuvable. Activez Google dans la console Firebase puis re-téléchargez GoogleService-Info.plist."
            return
        }
        guard let presenter = Self.topViewController() else {
            errorMessage = "Impossible d'afficher la fenêtre de connexion Google."
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        await perform {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingGoogleToken
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            try await Auth.auth().signIn(with: credential)
        }
    }

    // MARK: - Déconnexion

    func signOut() {
        guard isFirebaseConfigured else { return }
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            errorMessage = nil
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    // MARK: - Helpers

    private func perform(_ action: () async throws -> Void) async {
        guard isFirebaseConfigured else {
            errorMessage = "Firebase n'est pas configuré : ajoutez GoogleService-Info.plist au projet."
            return
        }
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        defer { isLoading = false }

        do {
            try await action()
        } catch let error as GIDSignInError where error.code == .canceled {
            // L'utilisateur a fermé la fenêtre Google : pas d'erreur à afficher.
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// Traduit une erreur Firebase en message français (interne pour les tests).
    static func message(for error: Error) -> String {
        if let error = error as? AuthError { return error.localizedDescription }

        let nsError = error as NSError
        guard nsError.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail: return "Adresse email invalide."
        case .emailAlreadyInUse: return "Cette adresse email est déjà utilisée."
        case .weakPassword: return "Mot de passe trop faible (6 caractères minimum)."
        case .wrongPassword, .invalidCredential, .userNotFound: return "Email ou mot de passe incorrect."
        case .networkError: return "Problème de connexion réseau."
        case .tooManyRequests: return "Trop de tentatives. Réessayez plus tard."
        case .operationNotAllowed: return "Ce mode de connexion n'est pas activé dans la console Firebase."
        case .accountExistsWithDifferentCredential: return "Un compte existe déjà avec cet email via un autre mode de connexion."
        default: return error.localizedDescription
        }
    }

    private static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    private enum AuthError: LocalizedError {
        case missingGoogleToken

        var errorDescription: String? {
            switch self {
            case .missingGoogleToken: return "Jeton Google manquant. Réessayez."
            }
        }
    }
}
