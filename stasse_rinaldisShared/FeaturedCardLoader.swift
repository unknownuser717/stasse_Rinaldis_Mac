import Foundation

/// Résultat du chargement de la carte du jour pour le widget.
struct FeaturedCardResult: Equatable {
    let card: CatalogCard?
    let errorMessage: String?
}

/// Logique du widget « Card of the Day », séparée de l'affichage pour être testée.
/// Les sources de données sont injectables : les tests n'utilisent pas le réseau.
enum FeaturedCardLoader {
    static let emptyCatalogMessage = "No cards were found."
    static let imageTimeout: TimeInterval = 10

    /// Charge le catalogue et choisit la carte du jour.
    static func load(
        on date: Date,
        cards: () async throws -> [CatalogCard] = { try await CardCatalog.load() }
    ) async -> FeaturedCardResult {
        do {
            let catalog = try await cards()
            guard let card = CatalogCard.featured(in: catalog, on: date) else {
                return FeaturedCardResult(card: nil, errorMessage: emptyCatalogMessage)
            }
            return FeaturedCardResult(card: card, errorMessage: nil)
        } catch {
            return FeaturedCardResult(card: nil, errorMessage: error.localizedDescription)
        }
    }

    /// Télécharge l'image de la carte. Renvoie `nil` en cas d'échec
    /// (erreur réseau, statut HTTP non 2xx ou réponse vide).
    static func imageData(
        for card: CatalogCard,
        fetch: (URLRequest) async throws -> (Data, URLResponse) = { try await URLSession.shared.data(for: $0) }
    ) async -> Data? {
        guard let url = card.imageURL else { return nil }
        do {
            let (data, response) = try await fetch(URLRequest(url: url, timeoutInterval: imageTimeout))
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode),
                  !data.isEmpty else { return nil }
            return data
        } catch {
            return nil
        }
    }
}
