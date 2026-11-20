import SwiftUI
import GoogleSignIn

@main
struct stasse_rinaldisApp: App {
    @StateObject private var vm = CardViewModel()
    @StateObject private var auth: AuthManager

    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")

    init() {
        let configured = FirebaseSetup.configureIfPossible()
        _auth = StateObject(wrappedValue: AuthManager(
            isFirebaseConfigured: configured,
            bypassForUITests: Self.isUITesting
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
