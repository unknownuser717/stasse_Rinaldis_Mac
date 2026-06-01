import SwiftUI

struct Card: Identifiable, Codable {
    let id: Int
    let name: String
    let elixirCost: Int
    let maxLevel: Int
    let rarity: String
    let maxEvolutionLevel: Int?
    let iconUrls: IconUrls?

    struct IconUrls: Codable {
        let medium: String?
    }

    var rarityName: String { rarity.capitalized }

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

struct CardResponse: Codable {
    let items: [Card]
}

extension Card {
    static let mockCards: [Card] = [
        Card(id: 1, name: "Knight", elixirCost: 3, maxLevel: 14, rarity: "COMMON", maxEvolutionLevel: 1, iconUrls: nil),
        Card(id: 2, name: "Archers", elixirCost: 3, maxLevel: 14, rarity: "COMMON", maxEvolutionLevel: 1, iconUrls: nil),
        Card(id: 3, name: "Balloon", elixirCost: 5, maxLevel: 14, rarity: "EPIC", maxEvolutionLevel: nil, iconUrls: nil),
    ]
}