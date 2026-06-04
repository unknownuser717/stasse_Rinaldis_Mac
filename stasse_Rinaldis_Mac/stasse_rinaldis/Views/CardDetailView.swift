import SwiftUI

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    statsSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .navigationTitle(card.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.08, green: 0.10, blue: 0.18), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.12, green: 0.15, blue: 0.25))
                    .frame(width: 140, height: 140)
                    .shadow(color: card.rarityColor.opacity(0.4), radius: 20)
                AsyncImage(url: URL(string: card.imageUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Text(card.emoji).font(.system(size: 72))
                }
                .frame(width: 110, height: 110)
            }

            Text(card.displayName)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))

            Text(card.rarityName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 18).padding(.vertical, 6)
                .background(Capsule().fill(card.rarityColor))
        }
    }

    private var statsSection: some View {
        VStack(spacing: 0) {
            Text("STATISTIQUES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            VStack(spacing: 1) {
                StatRow(icon: "⚡️", label: "Cout en Elixir",     value: "\(card.elixirCost ?? 0)")
                StatRow(icon: "🏆", label: "Niveau maximum",       value: "\(card.maxLevel)")
                StatRow(icon: "⭐️", label: "Rarete",             value: card.rarityName)
                StatRow(icon: "🔄", label: "Niveau evolution max", value: card.maxEvolutionLevel.map { "\($0)" } ?? "—")
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.12, green: 0.15, blue: 0.25)))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

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
    NavigationStack {
        CardDetailView(card: Card.mockCards[0])
    }
}