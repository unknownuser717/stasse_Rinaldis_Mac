import SwiftUI

struct ArenaListView: View {
    @EnvironmentObject var vm: CardViewModel

    var arenas: [Arena] {
        vm.arenas.filter { $0.isInUse }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                        .tint(Color(red: 0.95, green: 0.7, blue: 0.1))
                        .scaleEffect(1.5)
                } else {
                    List(arenas) { arena in
                        NavigationLink(destination: ArenaDetailView(arena: arena)) {
                            ArenaRow(arena: arena)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("🏟️ Arenas")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}