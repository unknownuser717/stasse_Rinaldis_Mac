import Foundation
import Testing
@testable import stasse_rinaldis

struct stasse_rinaldisTests {
    @Test @MainActor func filtersCardsBySearchAndRarityAndSortsByElixir() {
        let viewModel = CardViewModel()
        viewModel.cards = Card.mockCards
        viewModel.searchText = "a"
        viewModel.selectedRarity = "common"
        viewModel.sortOption = .elixir

        #expect(viewModel.filtered.map(\.name) == ["Archers"])

        viewModel.searchText = ""
        viewModel.selectedRarity = nil
        #expect(viewModel.filtered.last?.name == "Fireball")
    }

    @Test func featuredCardRotatesDailyAndHandlesEmptyCatalog() throws {
        let first = CatalogCard(id: 1, key: "knight", name: "Knight", elixir: 3, type: "Troop", rarity: "Common", description: "", arena: 0)
        let second = CatalogCard(id: 2, key: "archers", name: "Archers", elixir: 3, type: "Troop", rarity: "Common", description: "", arena: 0)
        let day = try #require(ISO8601DateFormatter().date(from: "2026-01-01T12:00:00Z"))
        let nextDay = try #require(Calendar.current.date(byAdding: .day, value: 1, to: day))
        let firstPick = try #require(CatalogCard.featured(in: [first, second], on: day))
        let nextPick = try #require(CatalogCard.featured(in: [first, second], on: nextDay))

        #expect(Set([firstPick.id, nextPick.id]) == Set([first.id, second.id]))
        #expect(CatalogCard.featured(in: [], on: day) == nil)
    }
}
