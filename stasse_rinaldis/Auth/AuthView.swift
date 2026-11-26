import SwiftUI
import GoogleSignInSwift

/// Écran de connexion / inscription : email + mot de passe, et Google.
struct AuthView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError: String?

    /// Pendant les tests UI, on coupe le remplissage automatique d'iOS
    /// (« mot de passe fort ») qui remplace ce que le test tape.
    private static let disablesAutofill = ProcessInfo.processInfo.arguments.contains("-ui-testing-auth")

    private let background = Color(red: 0.08, green: 0.10, blue: 0.18)
    private let gold = Color(red: 0.95, green: 0.7, blue: 0.1)

    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Connexion"
        case signUp = "Inscription"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    if !auth.isFirebaseConfigured {
                        notice("Firebase n'est pas encore configuré. Ajoutez GoogleService-Info.plist à la target stasse_rinaldis (voir README).",
                               color: .orange, id: "auth-config-warning")
                    }

                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("auth-mode-picker")

                    VStack(spacing: 12) {
                        field {
                            TextField("", text: $email, prompt: prompt("Email"))
                                .keyboardType(.emailAddress)
                                .textContentType(Self.disablesAutofill ? nil : .emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .accessibilityIdentifier("auth-email")
                        }
                        field {
                            SecureField("", text: $password, prompt: prompt("Mot de passe"))
                                .textContentType(Self.disablesAutofill ? nil : (mode == .signUp ? .newPassword : .password))
                                .accessibilityIdentifier("auth-password")
                        }
                        if mode == .signUp {
                            field {
                                SecureField("", text: $confirmPassword, prompt: prompt("Confirmer le mot de passe"))
                                    .textContentType(Self.disablesAutofill ? nil : .newPassword)
                                    .accessibilityIdentifier("auth-password-confirm")
                            }
                        }
                    }

                    if let message = localError ?? auth.errorMessage {
                        notice(message, color: .red)
                    } else if let info = auth.infoMessage {
                        notice(info, color: .green)
                    }

                    Button(action: submit) {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text(mode == .signIn ? "Se connecter" : "Créer un compte")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(gold)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(auth.isLoading)
                    .accessibilityIdentifier("auth-submit")

                    if mode == .signIn {
                        Button("Mot de passe oublié ?") {
                            guard validateEmail() else { return }
                            Task { await auth.resetPassword(email: trimmedEmail) }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    }

                    HStack {
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                        Text("OU").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.4))
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                    }

                    GoogleSignInButton(scheme: .light, style: .wide, state: auth.isLoading ? .disabled : .normal) {
                        localError = nil
                        Task { await auth.signInWithGoogle() }
                    }
                    .frame(height: 50)
                    .accessibilityIdentifier("auth-google")
                }
                .padding(24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: mode) {
            localError = nil
            auth.errorMessage = nil
            auth.infoMessage = nil
        }
    }

    // MARK: - Sous-vues

    private var header: some View {
        VStack(spacing: 8) {
            Text("🃏").font(.system(size: 56))
            Text("Stasse Rinaldis")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(gold)
            Text(mode == .signIn ? "Connectez-vous pour accéder aux cartes" : "Créez votre compte")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 32)
    }

    private func field<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .foregroundColor(.white)
            .padding(14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func prompt(_ text: String) -> Text {
        Text(text).foregroundColor(.white.opacity(0.4))
    }

    private func notice(_ text: String, color: Color, id: String = "auth-message") -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(color)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityIdentifier(id)
    }

    // MARK: - Actions

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validateEmail() -> Bool {
        localError = nil
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            localError = "Saisissez une adresse email valide."
            return false
        }
        return true
    }

    private func submit() {
        guard validateEmail() else { return }
        guard password.count >= 6 else {
            localError = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }
        if mode == .signUp && password != confirmPassword {
            localError = "Les mots de passe ne correspondent pas."
            return
        }

        Task {
            switch mode {
            case .signIn: await auth.signIn(email: trimmedEmail, password: password)
            case .signUp: await auth.signUp(email: trimmedEmail, password: password)
            }
        }
    }
}
