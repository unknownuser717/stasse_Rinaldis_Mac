import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // PASTE YOUR API KEY HERE
    private let apiKey = "PASTE_YOUR_KEY_HERE"

    var filtered: [Card] {
        searchText.isEmpty ? cards : cards.filter {
            $0.displayName.lowercased().contains(searchText.lowercased())
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
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse {
                print("Status code: \(http.statusCode)")
            }
            let decoded = try JSONDecoder().decode(CardResponse.self, from: data)
            cards = decoded.items
        } catch {
            print("Erreur API: \(error)")
            print("Erreur detail: \(error.localizedDescription)")
        }
    }
}
