import SwiftUI

struct CardRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.18))
                    .frame(width: 58, height: 58)
                if let imageUrl = card.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Text(card.emoji).font(.system(size: 32))
                    }
                    .frame(width: 50, height: 50)
                } else {
                    Text(card.emoji).font(.system(size: 32))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(card.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))

                HStack(spacing: 6) {
                    Circle()
                        .fill(card.rarityColor)
                        .frame(width: 8, height: 8)
                    Text(card.rarityName)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("⚡️").font(.system(size: 14))
                Text("\(card.elixirCost ?? 0)")
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

#Preview {
    CardRow(card: Card.mockCards[0])
        .padding()
        .background(Color(red: 0.08, green: 0.10, blue: 0.18))
}