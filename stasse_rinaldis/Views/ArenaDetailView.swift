import SwiftUI

struct ArenaDetailView: View {
    let arena: Arena
    @EnvironmentObject var vm: CardViewModel

    var arenaCards: [Card] {
        vm.cards.filter { $0.arena == arena.arenaId }
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.18).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    cardsSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .navigationTitle(arena.title)
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
                    .shadow(color: Color(red: 0.95, green: 0.7, blue: 0.1).opacity(0.3), radius: 20)
                AsyncImage(url: URL(string: arena.imageUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Text(arena.emoji).font(.system(size: 72))
                }
                .frame(width: 110, height: 110)
            }

            Text(arena.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))

            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))
                Text("\(arena.trophyLimit)+ trophies")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private var cardsSection: some View {
        VStack(spacing: 12) {
            Text("CARDS UNLOCKED")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .leading)

            if arenaCards.isEmpty {
                Text("No cards for this arena")
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(arenaCards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        CardRow(card: card)
                    }
                }
            }
        }
    }
}