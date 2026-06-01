import SwiftUI

struct CardListView: View {
    @StateObject private var vm = CardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                        .tint(Color(red: 0.95, green: 0.7, blue: 0.1))
                        .scaleEffect(1.5)
                } else {
                    List(vm.filtered) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardRow(card: card)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("⚔️ Clash Royale")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $vm.searchText, prompt: "Rechercher une carte...")
        }
        .task { await vm.load() }
    }
}

#Preview {
    CardListView()
}
