import SwiftUI

struct ArenaRow: View {
    let arena: Arena

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.18))
                    .frame(width: 58, height: 58)
                AsyncImage(url: URL(string: arena.imageUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Text(arena.emoji).font(.system(size: 32))
                }
                .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(arena.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.1))
                    Text("\(arena.trophyLimit)+")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            Spacer()

            Text("Arena \(arena.arenaId)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
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