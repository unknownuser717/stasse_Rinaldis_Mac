import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // ← PASTE YOUR API KEY HERE
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"

    var filtered: [Card] {
        searchText.isEmpty ? cards : cards.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    func load() async {
        isLoading = true
        await fetchAPI()
        isLoading = false
    }

    private func fetchAPI() async {
        guard let url = URL(string: "https://api.clashroyale.com/v1/cards?limit=200") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode(CardResponse.self, from: data)
            cards = decoded.items
        } catch {
            print("Erreur API: \(error)")
        }
    }
}