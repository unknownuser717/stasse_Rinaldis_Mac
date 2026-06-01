import SwiftUI

struct Card: Identifiable, Codable {
    let id: Int
    let elixirCost: Int
    let maxLevel: Int
    let rarity: String
    let maxEvolutionLevel: Int?
    let iconUrls: IconUrls?
    private let name: AnyCodable?

    struct IconUrls: Codable {
        let medium: String?
    }

    struct AnyCodable: Codable {
        let values: [String: String]
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            values = (try? container.decode([String: String].self)) ?? [:]
        }
        func encode(to encoder: Encoder) throws {}
    }

    var displayName: String {
        name?.values["en"] ?? name?.values.values.first ?? "Unknown"
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
    static let mockCards: [Card] = []
}