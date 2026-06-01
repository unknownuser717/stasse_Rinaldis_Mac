import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // PASTE YOUR API KEY HERE
    private let apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjJjMjM0N2FhLTk3ODMtNGE3Ni05ODlkLWFiZGYwM2FjYTQzNCIsImlhdCI6MTc4MDMwNzY1Nywic3ViIjoiZGV2ZWxvcGVyLzdjMzExZjgxLTNiN2QtZmVkYy04NjFhLTA3OGI1YjU4ZGFlYSIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyIxOTQuMjE0LjE3MS4xMyJdLCJ0eXBlIjoiY2xpZW50In1dfQ.F5BZ206oV5RxnCdUBUjbqubAnBI89qTnyJSVS7210-GBWQByzCvimTpGAR2HkBCNVzRL7dpinK26AW5licsnqA"

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
