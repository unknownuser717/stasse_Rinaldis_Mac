import SwiftUI

struct CardListView: View {
    @EnvironmentObject var vm: CardViewModel

    let rarities = ["Common", "Rare", "Epic", "Legendary", "Champion"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                        .tint(Color(red: 0.95, green: 0.7, blue: 0.1))
                        .scaleEffect(1.5)
                } else {
                    VStack(spacing: 0) {
                        // RARITY FILTER
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(label: "Tous", isSelected: vm.selectedRarity == nil) {
                                    vm.selectedRarity = nil
                                }
                                ForEach(rarities, id: \.self) { rarity in
                                    FilterChip(label: rarity, isSelected: vm.selectedRarity == rarity) {
                                        vm.selectedRarity = vm.selectedRarity == rarity ? nil : rarity
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }

                        // SORT PICKER
                        HStack {
                            Text("Trier par:")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                            Picker("Tri", selection: $vm.sortOption) {
                                ForEach(CardViewModel.SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

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
            }
            .navigationTitle("Clash Royale")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $vm.searchText, prompt: "Rechercher une carte...")
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0.95, green: 0.7, blue: 0.1) : Color(red: 0.2, green: 0.23, blue: 0.35))
                )
        }
    }
}

#Preview {
    CardListView()
        .environmentObject(CardViewModel())
}