import SwiftUI

struct Card: Identifiable {
    let id: Int
    let name: String
    let elixirCost: Int?
    let maxLevel: Int
    let rarity: String
    let maxEvolutionLevel: Int?
    let iconUrl: String?
    let type: String
    let description: String
    let arena: Int

    var imageUrl: String? { iconUrl }

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

extension Card {
    static let mockCards: [Card] = [
        Card(id: 26000000, name: "Knight", elixirCost: 3, maxLevel: 14, rarity: "COMMON", maxEvolutionLevel: 1, iconUrl: nil, type: "Troop", description: "A tough melee fighter.", arena: 0),
        Card(id: 26000001, name: "Archers", elixirCost: 3, maxLevel: 14, rarity: "COMMON", maxEvolutionLevel: 1, iconUrl: nil, type: "Troop", description: "A pair of ranged attackers.", arena: 0),
        Card(id: 28000000, name: "Fireball", elixirCost: 4, maxLevel: 14, rarity: "RARE", maxEvolutionLevel: nil, iconUrl: nil, type: "Spell", description: "Annnnnd... Fireball.", arena: 0),
    ]
}