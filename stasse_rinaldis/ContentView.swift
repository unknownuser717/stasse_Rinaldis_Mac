//
//  ContentView.swift
//  stasse_rinaldis
//
//  Created by Damien Rinaldis on 29/05/2026.
//

import SwiftUI

// MARK: - Modèle Card
struct Card: Identifiable {
    let id: Int
    let name: String
    let elixirCost: Int
    let maxLevel: Int
    let rarity: String
    let maxEvolutionLevel: Int?

    var emoji: String {
        switch rarity.lowercased() {
        case "legendary": return "👑"
        case "epic":      return "🔮"
        case "rare":      return "💎"
        case "champion":  return "🏅"
        default:          return "⚔️"
        }
    }

    var rarityColor: Color {
        switch rarity.lowercased() {
        case "legendary": return Color(red: 0.9, green: 0.5, blue: 0.1)
        case "epic":      return Color(red: 0.6, green: 0.2, blue: 0.9)
        case "rare":      return Color(red: 0.2, green: 0.4, blue: 0.9)
        case "champion":  return Color(red: 0.9, green: 0.1, blue: 0.2)
        default:          return Color(red: 0.3, green: 0.7, blue: 0.3)
        }
    }
}

// MARK: - Mock data
let mockCards: [Card] = [
    Card(id: 1,  name: "Knight",          elixirCost: 3, maxLevel: 14, rarity: "Common",    maxEvolutionLevel: 1),
    Card(id: 2,  name: "Archers",         elixirCost: 3, maxLevel: 14, rarity: "Common",    maxEvolutionLevel: 1),
    Card(id: 3,  name: "Balloon",         elixirCost: 5, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 4,  name: "Witch",           elixirCost: 5, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 5,  name: "Barbarians",      elixirCost: 5, maxLevel: 14, rarity: "Common",    maxEvolutionLevel: 1),
    Card(id: 6,  name: "Goblin Barrel",   elixirCost: 3, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 7,  name: "Giant",           elixirCost: 5, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 8,  name: "P.E.K.K.A",      elixirCost: 7, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 9,  name: "Musketeer",       elixirCost: 4, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 10, name: "Mini P.E.K.K.A", elixirCost: 4, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 11, name: "Fireball",        elixirCost: 4, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 12, name: "Arrows",          elixirCost: 3, maxLevel: 14, rarity: "Common",    maxEvolutionLevel: nil),
    Card(id: 13, name: "Goblin",          elixirCost: 2, maxLevel: 14, rarity: "Common",    maxEvolutionLevel: 1),
    Card(id: 14, name: "Giant Skeleton",  elixirCost: 6, maxLevel: 14, rarity: "Legendary", maxEvolutionLevel: nil),
    Card(id: 15, name: "Hog Rider",       elixirCost: 4, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 16, name: "Valkyrie",        elixirCost: 4, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 17, name: "Skeleton Army",   elixirCost: 3, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 18, name: "Freeze",          elixirCost: 4, maxLevel: 14, rarity: "Epic",      maxEvolutionLevel: nil),
    Card(id: 19, name: "Inferno Tower",   elixirCost: 5, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
    Card(id: 20, name: "Mega Minion",     elixirCost: 3, maxLevel: 14, rarity: "Rare",      maxEvolutionLevel: nil),
]

// MARK: - ViewModel
@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // 🔑 Remplace par ta vraie clé API : https://developer.clashroyale.com
    private let apiKey = "VOTRE_CLE_API_ICI"

    var filtered: [Card] {
        searchText.isEmpty ? cards : cards.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    func load() async {
        isLoading = true
        // Simule un chargement réseau
        try? await Task.sleep(nanoseconds: 500_000_000)

        // ✅ Mock actif — remplace par fetchAPI() quand tu as ta clé
        cards = mockCards

        // Pour activer l'API réelle, décommente :
        // await fetchAPI()
        isLoading = false
    }

    private func fetchAPI() async {
        guard let url = URL(string: "https://api.clashroyale.com/v1/cards") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        // Décoder la réponse JSON ici...
    }
}

// MARK: - Vue liste principale
struct ContentView: View {
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

// MARK: - Cellule
struct CardRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.18))
                    .frame(width: 58, height: 58)
                Text(card.emoji).font(.system(size: 32))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(card.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))

                HStack(spacing: 6) {
                    Circle().fill(card.rarityColor).frame(width: 8, height: 8)
                    Text(card.rarity)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("⚡️").font(.system(size: 14))
                Text("\(card.elixirCost)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.75, green: 0.45, blue: 1.0))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.12, green: 0.15, blue: 0.25))
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
        )
    }
}

// MARK: - Vue détail
struct CardDetailView: View {
    let card: Card

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.12, green: 0.15, blue: 0.25))
                                .frame(width: 140, height: 140)
                                .shadow(color: card.rarityColor.opacity(0.4), radius: 20)
                            Text(card.emoji).font(.system(size: 72))
                        }

                        Text(card.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))

                        Text(card.rarity)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18).padding(.vertical, 6)
                            .background(Capsule().fill(card.rarityColor))
                    }

                    // Stats
                    VStack(spacing: 0) {
                        Text("STATISTIQUES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 12)

                        VStack(spacing: 1) {
                            StatRow(icon: "⚡️", label: "Coût en Élixir",      value: "\(card.elixirCost)")
                            StatRow(icon: "🏆", label: "Niveau maximum",        value: "\(card.maxLevel)")
                            StatRow(icon: "⭐️", label: "Rareté",              value: card.rarity)
                            StatRow(icon: "🔄", label: "Niveau évolution max",  value: card.maxEvolutionLevel.map { "\($0)" } ?? "—")
                        }
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.12, green: 0.15, blue: 0.25)))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Ligne stat
struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(icon).font(.system(size: 20)).frame(width: 32)
            Text(label).font(.system(size: 15)).foregroundColor(.white.opacity(0.65))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(red: 0.12, green: 0.15, blue: 0.25))
        .overlay(Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1), alignment: .bottom)
    }
}

#Preview {
    ContentView()
}
