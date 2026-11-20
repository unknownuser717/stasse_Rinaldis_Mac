import Foundation

struct CatalogCard: Codable, Identifiable, Equatable {
    let id: Int
    let key: String
    let name: String
    let elixir: Int?
    let type: String
    let rarity: String
    let description: String
    let arena: Int

    static let preview = CatalogCard(
        id: 1,
        key: "knight",
        name: "Knight",
        elixir: 3,
        type: "Troop",
        rarity: "Common",
        description: "A tough melee fighter.",
        arena: 0
    )

    var imageURL: URL? {
        URL(string: "https://royaleapi.github.io/cr-api-assets/cards/\(key).png")
    }

    static func featured(in cards: [CatalogCard], on date: Date) -> CatalogCard? {
        guard !cards.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return cards[(dayOfYear - 1) % cards.count]
    }
}

enum CardCatalog {
    private static let url = URL(string: "https://royaleapi.github.io/cr-api-data/json/cards.json")!

    static func load() async throws -> [CatalogCard] {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CatalogError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw CatalogError.httpStatus(httpResponse.statusCode)
        }
        return try JSONDecoder().decode([CatalogCard].self, from: data)
    }
}

enum CatalogError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The card catalog returned an invalid response."
        case .httpStatus(let status):
            return "The card catalog request failed with HTTP status \(status)."
        }
    }
}
