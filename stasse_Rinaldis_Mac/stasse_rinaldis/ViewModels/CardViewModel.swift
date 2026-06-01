//
//  CardViewModel.swift
//  stasse_rinaldis
//

import Foundation

// MARK: - ViewModel
@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // 🔑 Remplace par ta vraie clé API : https://developer.clashroyale.com
    private let apiKey = "VOTRE_CLE_API_ICI"

    var filtered: [Card] {
        searchText.isEmpty ? cards : cards.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    func load() async {
        isLoading = true
        // Simule un chargement réseau
        try? await Task.sleep(nanoseconds: 500_000_000)

        // ✅ Mock actif — remplace par fetchAPI() quand tu as ta clé
        cards = Card.mockCards

        // Pour activer l'API réelle, décommente :
        // await fetchAPI()
        isLoading = false
    }

    private func fetchAPI() async {
        guard let url = URL(string: "https://api.clashroyale.com/v1/cards") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }
            // Décoder ici quand l'API est branchée
            let _ = data
        } catch {
            print("Erreur API: \(error)")
        }
    }
}
