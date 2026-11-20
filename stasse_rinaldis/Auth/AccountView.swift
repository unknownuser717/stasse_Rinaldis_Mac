import SwiftUI

/// Onglet « Compte » : affiche l'utilisateur connecté et le bouton de déconnexion.
struct AccountView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var confirmSignOut = false

    private let background = Color(red: 0.08, green: 0.10, blue: 0.18)
    private let gold = Color(red: 0.95, green: 0.7, blue: 0.1)

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(gold)

                    if let name = auth.user?.displayName, !name.isEmpty {
                        Text(name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(auth.user?.email ?? "Non connecté")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .accessibilityIdentifier("account-email")

                    if let provider = providerName {
                        Text("Connecté via \(provider)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    if let message = auth.errorMessage {
                        Text(message)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }

                    Spacer()

                    Button(role: .destructive) {
                        confirmSignOut = true
                    } label: {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(auth.user == nil)
                    .accessibilityIdentifier("account-sign-out")
                }
                .padding(24)
                .padding(.top, 24)
            }
            .navigationTitle("Compte")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog("Se déconnecter ?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Se déconnecter", role: .destructive) { auth.signOut() }
                Button("Annuler", role: .cancel) {}
            }
        }
    }

    private var providerName: String? {
        let ids = auth.user?.providerData.map(\.providerID) ?? []
        if ids.contains("google.com") { return "Google" }
        if ids.contains("password") { return "email" }
        return nil
    }
}
