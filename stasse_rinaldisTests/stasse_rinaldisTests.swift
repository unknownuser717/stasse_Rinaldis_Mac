import Foundation
import Testing
@testable import stasse_rinaldis

struct stasse_rinaldisTests {
    @Test @MainActor func emptyViewModelHasNoFilteredCards() {
        #expect(CardViewModel().filtered.isEmpty)
    }

    @Test @MainActor func defaultSortOrdersCardsByName() {
        let viewModel = makeViewModel()

        #expect(viewModel.filtered.map(\.name) == ["Archers", "Fireball", "Knight"])
    }

    @Test @MainActor func searchIsCaseInsensitiveAndMatchesSubstrings() {
        let viewModel = makeViewModel()
        viewModel.searchText = "FIRE"

        #expect(viewModel.filtered.map(\.name) == ["Fireball"])
    }

    @Test @MainActor func unmatchedSearchReturnsNoCards() {
        let viewModel = makeViewModel()
        viewModel.searchText = "dragon"

        #expect(viewModel.filtered.isEmpty)
    }

    @Test @MainActor func rarityFilterIsCaseInsensitive() {
        let viewModel = makeViewModel()
        viewModel.selectedRarity = "common"

        #expect(Set(viewModel.filtered.map(\.name)) == Set(["Knight", "Archers"]))
    }

    @Test @MainActor func searchAndRarityFiltersAreAppliedTogether() {
        let viewModel = makeViewModel()
        viewModel.searchText = "a"
        viewModel.selectedRarity = "COMMON"

        #expect(viewModel.filtered.map(\.name) == ["Archers"])
    }

    @Test @MainActor func clearingRarityFilterRestoresSearchResults() {
        let viewModel = makeViewModel()
        viewModel.searchText = "a"
        viewModel.selectedRarity = "common"
        #expect(viewModel.filtered.map(\.name) == ["Archers"])

        viewModel.selectedRarity = nil

        #expect(Set(viewModel.filtered.map(\.name)) == Set(["Archers", "Fireball"]))
    }

    @Test @MainActor func elixirSortTreatsMissingCostAsZero() {
        let viewModel = CardViewModel()
        viewModel.cards = [
            makeCard(id: 1, name: "Costly", elixir: 5),
            makeCard(id: 2, name: "Unknown", elixir: nil),
            makeCard(id: 3, name: "Cheap", elixir: 2),
        ]
        viewModel.sortOption = .elixir

        #expect(viewModel.filtered.map(\.name) == ["Unknown", "Cheap", "Costly"])
    }

    @Test @MainActor func raritySortOrdersKnownRarities() {
        let viewModel = CardViewModel()
        viewModel.cards = [
            makeCard(id: 1, name: "Champion", rarity: "CHAMPION"),
            makeCard(id: 2, name: "Epic", rarity: "EPIC"),
            makeCard(id: 3, name: "Common", rarity: "COMMON"),
            makeCard(id: 4, name: "Legendary", rarity: "LEGENDARY"),
            makeCard(id: 5, name: "Rare", rarity: "RARE"),
        ]
        viewModel.sortOption = .rarity

        #expect(viewModel.filtered.map(\.name) == ["Common", "Rare", "Epic", "Legendary", "Champion"])
    }

    @Test func cardRarityLabelAndEmojiHandleEachKnownRarity() {
        let expected = [
            ("COMMON", "Common", "⚔️"),
            ("RARE", "Rare", "💎"),
            ("EPIC", "Epic", "🔮"),
            ("LEGENDARY", "Legendary", "👑"),
            ("CHAMPION", "Champion", "🏅"),
        ]

        for (rarity, label, emoji) in expected {
            let card = makeCard(id: 1, name: "Test", rarity: rarity)
            #expect(card.rarityName == label)
            #expect(card.emoji == emoji)
        }
    }

    @Test func unknownCardRarityUsesDefaultEmoji() {
        #expect(makeCard(id: 1, name: "Test", rarity: "mythic").emoji == "⚔️")
    }

    @Test func arenaDecoderMapsSnakeCaseFields() throws {
        let json = """
        {
          "id": 7,
          "key": "bone_pit",
          "title": "Bone Pit",
          "subtitle": "A test arena",
          "arena_id": 1,
          "trophy_limit": 300,
          "is_in_use": true
        }
        """

        let arena = try JSONDecoder().decode(Arena.self, from: Data(json.utf8))

        #expect(arena.arenaId == 1)
        #expect(arena.trophyLimit == 300)
        #expect(arena.isInUse)
    }

    @Test func arenaEmojiHasFallbackForUnknownArena() {
        let knownArena = makeArena(id: 1, arenaId: 1)
        let unknownArena = makeArena(id: 2, arenaId: 99)

        #expect(knownArena.emoji == "🥩")
        #expect(unknownArena.emoji == "🏆")
    }

    @Test func apiCardDecoderSupportsOptionalFields() throws {
        let json = """
        {
          "id": 26000000,
          "elixirCost": 3,
          "maxLevel": 14,
          "rarity": "common",
          "iconUrls": { "medium": "https://example.test/knight.png" }
        }
        """

        let card = try JSONDecoder().decode(APICard.self, from: Data(json.utf8))

        #expect(card.id == 26000000)
        #expect(card.elixirCost == 3)
        #expect(card.maxEvolutionLevel == nil)
        #expect(card.iconUrls?.medium == "https://example.test/knight.png")
    }

    @Test func staticCardDecoderReadsCatalogFields() throws {
        let json = """
        {
          "id": 26000000,
          "key": "knight",
          "name": "Knight",
          "elixir": 3,
          "type": "Troop",
          "rarity": "common",
          "description": "A tough melee fighter.",
          "arena": 0
        }
        """

        let card = try JSONDecoder().decode(StaticCard.self, from: Data(json.utf8))

        #expect(card.name == "Knight")
        #expect(card.elixir == 3)
        #expect(card.type == "Troop")
        #expect(card.arena == 0)
    }

    @Test func featuredCardIsStableForTheSameDayAndRotatesTheNextDay() throws {
        let first = makeCatalogCard(id: 1, key: "knight", name: "Knight")
        let second = makeCatalogCard(id: 2, key: "archers", name: "Archers")
        let day = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12)))
        let nextDay = try #require(Calendar.current.date(byAdding: .day, value: 1, to: day))
        let firstPick = try #require(CatalogCard.featured(in: [first, second], on: day))
        let sameDayPick = try #require(CatalogCard.featured(in: [first, second], on: day))
        let nextDayPick = try #require(CatalogCard.featured(in: [first, second], on: nextDay))

        #expect(firstPick == sameDayPick)
        #expect(firstPick.id != nextDayPick.id)
    }

    @Test func featuredCardHandlesEmptyAndSingleCardCatalogs() {
        let card = makeCatalogCard(id: 8, key: "knight", name: "Knight")

        #expect(CatalogCard.featured(in: [], on: .now) == nil)
        #expect(CatalogCard.featured(in: [card], on: .now) == card)
    }

    @Test func catalogCardBuildsItsImageURLFromTheCardKey() throws {
        let card = makeCatalogCard(id: 1, key: "knight", name: "Knight")
        let expectedURL = try #require(URL(string: "https://royaleapi.github.io/cr-api-assets/cards/knight.png"))

        #expect(card.imageURL == expectedURL)
    }

    @MainActor
    private func makeViewModel() -> CardViewModel {
        let viewModel = CardViewModel()
        viewModel.cards = Card.mockCards
        return viewModel
    }

    private func makeCard(
        id: Int,
        name: String,
        elixir: Int? = 3,
        rarity: String = "COMMON"
    ) -> Card {
        Card(
            id: id,
            name: name,
            elixirCost: elixir,
            maxLevel: 14,
            rarity: rarity,
            maxEvolutionLevel: nil,
            iconUrl: nil,
            type: "Troop",
            description: "",
            arena: 0
        )
    }

    private func makeArena(id: Int, arenaId: Int) -> Arena {
        Arena(
            id: id,
            key: "arena-\(arenaId)",
            title: "Arena \(arenaId)",
            subtitle: "",
            arenaId: arenaId,
            trophyLimit: 0,
            isInUse: true
        )
    }

    private func makeCatalogCard(id: Int, key: String, name: String) -> CatalogCard {
        CatalogCard(
            id: id,
            key: key,
            name: name,
            elixir: 3,
            type: "Troop",
            rarity: "Common",
            description: "",
            arena: 0
        )
    }
}
