import Foundation
import Combine

/// Modèle de l'app Apple Watch : charge le catalogue et calcule les stats.
/// Il est dans le dossier partagé pour que les tests unitaires puissent le tester.
@MainActor
final class WatchCatalogModel: ObservableObject {
    static let rarities = ["Common", "Rare", "Epic", "Legendary", "Champion"]

    @Published private(set) var cards: [CatalogCard] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let loader: @Sendable () async throws -> [CatalogCard]

    /// - Parameter loader: source des cartes. Par défaut le catalogue RoyaleAPI ;
    ///   les tests passent un faux chargeur pour ne pas dépendre du réseau.
    init(loader: @escaping @Sendable () async throws -> [CatalogCard] = { try await CardCatalog.load() }) {
        self.loader = loader
    }

    var averageElixir: Double {
        let costs = cards.compactMap(\.elixir)
        guard !costs.isEmpty else { return 0 }
        return Double(costs.reduce(0, +)) / Double(costs.count)
    }

    func count(rarity: String) -> Int {
        cards.filter { $0.rarity.caseInsensitiveCompare(rarity) == .orderedSame }.count
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            cards = try await loader()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
