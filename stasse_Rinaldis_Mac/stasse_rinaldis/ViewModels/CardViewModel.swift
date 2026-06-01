import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // PASTE YOUR API KEY HERE
    private let apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6ImE1NzUzMzYxLTRlYTgtNGI2YS04YjcwLWYyYzJlMzM2OTg3NSIsImlhdCI6MTc4MDMwNTgxNCwic3ViIjoiZGV2ZWxvcGVyLzdjMzExZjgxLTNiN2QtZmVkYy04NjFhLTA3OGI1YjU4ZGFlYSIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyIxOTMuNTAuMTM1LjIwMiJdLCJ0eXBlIjoiY2xpZW50In1dfQ.apZnwKkeCpU9qJPkdieV2nZI4h6cqvGApdPlY7NR9x6MPjWswQwY9yKFwyL5GamUz2LY5NuQEwX695tEh1dezg"

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
