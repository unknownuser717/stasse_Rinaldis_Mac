import Foundation
import Testing
@testable import stasse_rinaldis

/// Tests du modèle de l'app Apple Watch (sans réseau : faux chargeur).
@MainActor
struct WatchCatalogModelTests {

    // MARK: - État initial

    @Test func newModelIsEmpty() {
        let model = WatchCatalogModel(loader: { [] })

        #expect(model.cards.isEmpty)
        #expect(model.errorMessage == nil)
        #expect(model.isLoading == false)
        #expect(model.averageElixir == 0)
    }

    // MARK: - Chargement

    @Test func successfulLoadStoresCards() async {
        let cards = sampleCards()
        let model = WatchCatalogModel(loader: { cards })

        await model.load()

        #expect(model.cards == cards)
        #expect(model.errorMessage == nil)
        #expect(model.isLoading == false)
    }

    @Test func failedLoadShowsErrorMessage() async {
        let model = WatchCatalogModel(loader: { throw CatalogError.httpStatus(503) })

        await model.load()

        #expect(model.cards.isEmpty)
        #expect(model.errorMessage == "The card catalog request failed with HTTP status 503.")
        #expect(model.isLoading == false)
    }

    @Test func retryAfterFailureClearsError() async {
        let shouldFail = Flag(true)
        let cards = sampleCards()
        let model = WatchCatalogModel(loader: {
            if shouldFail.value { throw CatalogError.invalidResponse }
            return cards
        })

        await model.load()
        #expect(model.errorMessage != nil)

        shouldFail.value = false
        await model.load()

        #expect(model.errorMessage == nil)
        #expect(model.cards == cards)
    }

    @Test func failedReloadKeepsPreviouslyLoadedCards() async {
        let shouldFail = Flag(false)
        let cards = sampleCards()
        let model = WatchCatalogModel(loader: {
            if shouldFail.value { throw CatalogError.invalidResponse }
            return cards
        })

        await model.load()
        shouldFail.value = true
        await model.load()

        #expect(model.cards == cards)
        #expect(model.errorMessage == "The card catalog returned an invalid response.")
    }

    // MARK: - Stats

    @Test func averageElixirIgnoresCardsWithoutCost() async {
        let model = WatchCatalogModel(loader: {
            [
                makeCard(id: 1, elixir: 2),
                makeCard(id: 2, elixir: 5),
                makeCard(id: 3, elixir: nil),
            ]
        })

        await model.load()

        #expect(model.averageElixir == 3.5)
    }

    @Test func averageElixirIsZeroWhenNoCardHasACost() async {
        let model = WatchCatalogModel(loader: { [makeCard(id: 1, elixir: nil)] })

        await model.load()

        #expect(model.averageElixir == 0)
    }

    @Test func rarityCountIsCaseInsensitive() async {
        let model = WatchCatalogModel(loader: {
            [
                makeCard(id: 1, rarity: "Common"),
                makeCard(id: 2, rarity: "common"),
                makeCard(id: 3, rarity: "LEGENDARY"),
            ]
        })

        await model.load()

        #expect(model.count(rarity: "Common") == 2)
        #expect(model.count(rarity: "Legendary") == 1)
        #expect(model.count(rarity: "Champion") == 0)
    }

    @Test func rarityCountsAddUpToTotalForKnownRarities() async {
        let cards = sampleCards()
        let model = WatchCatalogModel(loader: { cards })

        await model.load()

        let total = WatchCatalogModel.rarities.map { model.count(rarity: $0) }.reduce(0, +)
        #expect(total == cards.count)
    }

    @Test func statsScreenListsTheFiveRarities() {
        #expect(WatchCatalogModel.rarities == ["Common", "Rare", "Epic", "Legendary", "Champion"])
    }

    // MARK: - Helpers

    private func sampleCards() -> [CatalogCard] {
        [
            makeCard(id: 1, elixir: 3, rarity: "Common"),
            makeCard(id: 2, elixir: 4, rarity: "Rare"),
            makeCard(id: 3, elixir: 5, rarity: "Epic"),
            makeCard(id: 4, elixir: 6, rarity: "Legendary"),
            makeCard(id: 5, elixir: 4, rarity: "Champion"),
        ]
    }
}

private func makeCard(id: Int, elixir: Int? = 3, rarity: String = "Common") -> CatalogCard {
    CatalogCard(
        id: id,
        key: "card-\(id)",
        name: "Card \(id)",
        elixir: elixir,
        type: "Troop",
        rarity: rarity,
        description: "",
        arena: 0
    )
}

/// Petit drapeau modifiable partagé avec le faux chargeur.
private final class Flag: @unchecked Sendable {
    var value: Bool
    init(_ value: Bool) { self.value = value }
}
