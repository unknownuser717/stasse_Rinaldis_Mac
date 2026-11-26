import Foundation
import Testing
@testable import stasse_rinaldis

/// Tests de la logique de connexion Firebase, sans réseau ni vrai compte.
/// Les managers sont créés avec `isFirebaseConfigured: false` : aucun appel n'est
/// envoyé à Firebase.
@MainActor
struct AuthManagerTests {
    private let notConfiguredMessage = "Firebase n'est pas configuré : ajoutez GoogleService-Info.plist au projet."

    // MARK: - État

    @Test func newManagerIsSignedOut() {
        let auth = AuthManager(isFirebaseConfigured: false)

        #expect(auth.isAuthenticated == false)
        #expect(auth.user == nil)
        #expect(auth.errorMessage == nil)
        #expect(auth.infoMessage == nil)
        #expect(auth.isLoading == false)
    }

    @Test func uiTestBypassCountsAsSignedIn() {
        let auth = AuthManager(isFirebaseConfigured: false, bypassForUITests: true)

        #expect(auth.isAuthenticated)
    }

    // MARK: - Sans configuration Firebase

    @Test func signInWithoutFirebaseShowsConfigurationError() async {
        let auth = AuthManager(isFirebaseConfigured: false)

        await auth.signIn(email: "test@test.com", password: "123456")

        #expect(auth.errorMessage == notConfiguredMessage)
        #expect(auth.isAuthenticated == false)
        #expect(auth.isLoading == false)
    }

    @Test func signUpWithoutFirebaseShowsConfigurationError() async {
        let auth = AuthManager(isFirebaseConfigured: false)

        await auth.signUp(email: "test@test.com", password: "123456")

        #expect(auth.errorMessage == notConfiguredMessage)
        #expect(auth.isAuthenticated == false)
    }

    @Test func passwordResetWithoutFirebaseDoesNotClaimEmailWasSent() async {
        let auth = AuthManager(isFirebaseConfigured: false)

        await auth.resetPassword(email: "test@test.com")

        #expect(auth.errorMessage == notConfiguredMessage)
        #expect(auth.infoMessage == nil)
    }

    @Test func signOutWithoutFirebaseDoesNothing() {
        let auth = AuthManager(isFirebaseConfigured: false)

        auth.signOut()

        #expect(auth.errorMessage == nil)
        #expect(auth.isAuthenticated == false)
    }

    // MARK: - Messages d'erreur en français

    @Test(arguments: [
        (17008, "Adresse email invalide."),
        (17007, "Cette adresse email est déjà utilisée."),
        (17026, "Mot de passe trop faible (6 caractères minimum)."),
        (17009, "Email ou mot de passe incorrect."),
        (17004, "Email ou mot de passe incorrect."),
        (17011, "Email ou mot de passe incorrect."),
        (17020, "Problème de connexion réseau."),
        (17010, "Trop de tentatives. Réessayez plus tard."),
        (17006, "Ce mode de connexion n'est pas activé dans la console Firebase."),
        (17012, "Un compte existe déjà avec cet email via un autre mode de connexion."),
    ])
    func firebaseErrorsAreTranslated(code: Int, expected: String) {
        let error = NSError(domain: "FIRAuthErrorDomain", code: code)

        #expect(AuthManager.message(for: error) == expected)
    }

    @Test func otherErrorsKeepTheirOwnDescription() {
        let error = NSError(
            domain: "OtherDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Autre erreur"]
        )

        #expect(AuthManager.message(for: error) == "Autre erreur")
    }
}
