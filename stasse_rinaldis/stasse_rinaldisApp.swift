import SwiftUI
import GoogleSignIn

@main
struct stasse_rinaldisApp: App {
    @StateObject private var vm = CardViewModel()
    @StateObject private var auth: AuthManager

    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
    /// Tests UI de l'écran de connexion : affiche AuthView sans Firebase,
    /// pour des tests hors ligne et toujours dans le même état.
    private static let isAuthUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing-auth")

    init() {
        // En tests UI, Firebase n'est pas démarré : lancement plus rapide et hors ligne.
        let configured = (Self.isUITesting || Self.isAuthUITesting) ? false : FirebaseSetup.configureIfPossible()
        _auth = StateObject(wrappedValue: AuthManager(
            isFirebaseConfigured: configured,
            bypassForUITests: Self.isUITesting && !Self.isAuthUITesting
        ))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    mainTabs
                } else {
                    AuthView()
                }
            }
            .environmentObject(auth)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .tint(Color(red: 0.95, green: 0.7, blue: 0.1))
        }
    }

    private var mainTabs: some View {
        TabView {
            CardListView()
                .tabItem {
                    Label("Cards", systemImage: "rectangle.stack.fill")
                }

            ArenaListView()
                .tabItem {
                    Label("Arenas", systemImage: "trophy.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            AccountView()
                .tabItem {
                    Label("Compte", systemImage: "person.crop.circle.fill")
                }
        }
        .environmentObject(vm)
        .task {
            if Self.isUITesting {
                vm.cards = Card.mockCards
                vm.arenas = Arena.mockArenas
            } else if vm.cards.isEmpty {
                await vm.load()
            }
        }
    }
}
