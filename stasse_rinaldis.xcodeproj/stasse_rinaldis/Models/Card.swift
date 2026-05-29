//
//  Card.swift
//  stasse_rinaldis
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

// MARK: - Mock Data
extension Card {
    static let mockCards: [Card] = [
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
}
