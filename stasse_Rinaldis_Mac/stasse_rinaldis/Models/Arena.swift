import SwiftUI

struct Arena: Identifiable, Codable {
    let id: Int
    let key: String
    let title: String
    let subtitle: String
    let arenaId: Int
    let trophyLimit: Int
    let isInUse: Bool

    enum CodingKeys: String, CodingKey {
        case id, key, title, subtitle
        case arenaId = "arena_id"
        case trophyLimit = "trophy_limit"
        case isInUse = "is_in_use"
    }

    var imageUrl: String {
        "https://royaleapi.github.io/cr-api-assets/arenas/\(key).png"
    }

    var emoji: String {
        switch arenaId {
        case 0:  return "🏕️"
        case 1:  return "🥩"
        case 2:  return "🏗️"
        case 3:  return "🌊"
        case 4:  return "⚡️"
        case 5:  return "🍖"
        case 6:  return "🧟"
        case 7:  return "🧙"
        case 8:  return "🌋"
        case 9:  return "🤴"
        case 10: return "🔮"
        case 11: return "❄️"
        case 12: return "👑"
        default: return "🏆"
        }
    }
}