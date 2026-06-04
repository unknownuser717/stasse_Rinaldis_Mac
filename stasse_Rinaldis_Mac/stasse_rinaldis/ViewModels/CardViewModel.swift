import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    private let apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjJjMjM0N2FhLTk3ODMtNGE3Ni05ODlkLWFiZGYwM2FjYTQzNCIsImlhdCI6MTc4MDMwNzY1Nywic3ViIjoiZGV2ZWxvcGVyLzdjMzExZjgxLTNiN2QtZmVkYy04NjFhLTA3OGI1YjU4ZGFlYSIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyIxOTQuMjE0LjE3MS4xMyJdLCJ0eXBlIjoiY2xpZW50In1dfQ.F5BZ206oV5RxnCdUBUjbqubAnBI89qTnyJSVS7210-GBWQByzCvimTpGAR2HkBCNVzRL7dpinK26AW5licsnqA"

    var filtered: [Card] {
        searchText.isEmpty ? cards : cards.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    func load() async {
        isLoading = true
        async let apiCards = fetchAPICards()
        async let staticCards = fetchStaticCards()
        let (api, static_) = await (apiCards, staticCards)
        cards = merge(api: api, static_: static_)
        isLoading = false
    }

    // OFFICIAL API - gets rarity, elixirCost, maxLevel, iconUrls
    private func fetchAPICards() async -> [APICard] {
        guard let url = URL(string: "https://api.clashroyale.com/v1/cards?limit=200") else { return [] }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse {
                print("API status: \(http.statusCode)")
            }
            let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
            return decoded.items
        } catch {
            print("API error: \(error)")
            return []
        }
    }

    // STATIC JSON - gets name, type, description, arena
    private func fetchStaticCards() async -> [StaticCard] {
        guard let url = URL(string: "https://royaleapi.github.io/cr-api-data/json/cards.json") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([StaticCard].self, from: data)
        } catch {
            print("Static error: \(error)")
            return []
        }
    }

    // MERGE by id
    private func merge(api: [APICard], static_: [StaticCard]) -> [Card] {
        let staticMap = Dictionary(uniqueKeysWithValues: static_.map { ($0.id, $0) })
        return api.compactMap { apiCard in
            guard let staticCard = staticMap[apiCard.id] else { return nil }
            return Card(
                id: apiCard.id,
                name: staticCard.name,
                elixirCost: apiCard.elixirCost,
                maxLevel: apiCard.maxLevel,
                rarity: apiCard.rarity,
                maxEvolutionLevel: apiCard.maxEvolutionLevel,
                iconUrl: apiCard.iconUrls?.medium,
                type: staticCard.type,
                description: staticCard.description,
                arena: staticCard.arena
            )
        }
    }
}

// MARK: - API Models
struct APIResponse: Codable {
    let items: [APICard]
}

struct APICard: Codable {
    let id: Int
    let elixirCost: Int?
    let maxLevel: Int
    let rarity: String
    let maxEvolutionLevel: Int?
    let iconUrls: IconUrls?

    struct IconUrls: Codable {
        let medium: String?
    }
}

// MARK: - Static Models
struct StaticCard: Codable {
    let id: Int
    let key: String
    let name: String
    let elixir: Int?
    let type: String
    let rarity: String
    let description: String
    let arena: Int
}