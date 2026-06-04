import SwiftUI

@main
struct stasse_rinaldisApp: App {
    @StateObject private var vm = CardViewModel()

    var body: some Scene {
        WindowGroup {
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
            }
            .environmentObject(vm)
            .task { await vm.load() }
            .tint(Color(red: 0.95, green: 0.7, blue: 0.1))
        }
    }
}