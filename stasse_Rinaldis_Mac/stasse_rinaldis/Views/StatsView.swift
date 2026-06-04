import SwiftUI

struct StatsView: View {
    @EnvironmentObject var vm: CardViewModel

    var totalCards: Int { vm.cards.count }
    var avgElixir: Double {
        let costs = vm.cards.compactMap { $0.elixirCost }
        return costs.isEmpty ? 0 : Double(costs.reduce(0, +)) / Double(costs.count)
    }

    func count(rarity: String) -> Int {
        vm.cards.filter { $0.rarity.lowercased() == rarity.lowercased() }.count
    }

    func count(type: String) -> Int {
        vm.cards.filter { $0.type.lowercased() == type.lowercased() }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // TOTAL
                        StatCard(icon: "🃏", title: "Total Cartes", value: "\(totalCards)", color: Color(red: 0.95, green: 0.7, blue: 0.1))

                        // ELIXIR MOYEN
                        StatCard(icon: "🟣", title: "Elixir Moyen", value: String(format: "%.1f", avgElixir), color: Color(red: 0.75, green: 0.45, blue: 1.0))

                        // PAR RARETÉ
                        VStack(spacing: 0) {
                            Text("PAR RARETÉ")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 12)

                            VStack(spacing: 1) {
                                StatRow(icon: "⚔️", label: "Common",    value: "\(count(rarity: "common"))")
                                StatRow(icon: "💎", label: "Rare",       value: "\(count(rarity: "rare"))")
                                StatRow(icon: "🔮", label: "Epic",       value: "\(count(rarity: "epic"))")
                                StatRow(icon: "👑", label: "Legendary",  value: "\(count(rarity: "legendary"))")
                                StatRow(icon: "🏅", label: "Champion",   value: "\(count(rarity: "champion"))")
                            }
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.12, green: 0.15, blue: 0.25)))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        // PAR TYPE
                        VStack(spacing: 0) {
                            Text("PAR TYPE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 12)

                            VStack(spacing: 1) {
                                StatRow(icon: "🧙", label: "Troop",    value: "\(count(type: "troop"))")
                                StatRow(icon: "✨", label: "Spell",    value: "\(count(type: "spell"))")
                                StatRow(icon: "🏰", label: "Building", value: "\(count(type: "building"))")
                            }
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.12, green: 0.15, blue: 0.25)))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("📊 Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(icon).font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.12, green: 0.15, blue: 0.25)))
    }
}

#Preview {
    StatsView()
        .environmentObject(CardViewModel())
}