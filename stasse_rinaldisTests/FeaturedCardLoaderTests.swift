import Foundation
import Testing
@testable import stasse_rinaldis

/// Tests de la logique du widget « Card of the Day » (sans réseau).
struct FeaturedCardLoaderTests {

    // MARK: - Carte du jour

    @Test func loadPicksTheFeaturedCardForTheDate() async throws {
        let cards = sampleCards()
        let date = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 2)))

        let result = await FeaturedCardLoader.load(on: date, cards: { cards })

        #expect(result.card == CatalogCard.featured(in: cards, on: date))
        #expect(result.card?.id == 2) // 2e jour de l'année -> 2e carte
        #expect(result.errorMessage == nil)
    }

    @Test func loadGivesTheSameCardAllDay() async throws {
        let cards = sampleCards()
        let calendar = Calendar.current
        let morning = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 0, minute: 5)))
        let evening = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 23, minute: 55)))

        let first = await FeaturedCardLoader.load(on: morning, cards: { cards })
        let second = await FeaturedCardLoader.load(on: evening, cards: { cards })

        #expect(first.card == second.card)
    }

    @Test func loadWithEmptyCatalogShowsMessage() async {
        let result = await FeaturedCardLoader.load(on: .now, cards: { [] })

        #expect(result.card == nil)
        #expect(result.errorMessage == FeaturedCardLoader.emptyCatalogMessage)
    }

    @Test func loadFailureShowsErrorMessage() async {
        let result = await FeaturedCardLoader.load(on: .now, cards: { throw CatalogError.httpStatus(500) })

        #expect(result.card == nil)
        #expect(result.errorMessage == "The card catalog request failed with HTTP status 500.")
    }

    // MARK: - Image de la carte

    @Test func imageIsDownloadedFromTheCardImageURL() async throws {
        let card = sampleCards()[0]
        let expectedURL = try #require(card.imageURL)
        var requested: URLRequest?

        let data = await FeaturedCardLoader.imageData(for: card) { request in
            requested = request
            return (Data([1, 2, 3]), response(for: request.url!, status: 200))
        }

        #expect(data == Data([1, 2, 3]))
        #expect(requested?.url == expectedURL)
        #expect(requested?.timeoutInterval == FeaturedCardLoader.imageTimeout)
    }

    @Test(arguments: [404, 500])
    func imageIsNilWhenServerReturnsAnError(status: Int) async {
        let data = await FeaturedCardLoader.imageData(for: sampleCards()[0]) { request in
            (Data([1, 2, 3]), response(for: request.url!, status: status))
        }

        #expect(data == nil)
    }

    @Test func imageIsNilWhenResponseIsEmpty() async {
        let data = await FeaturedCardLoader.imageData(for: sampleCards()[0]) { request in
            (Data(), response(for: request.url!, status: 200))
        }

        #expect(data == nil)
    }

    @Test func imageIsNilWhenOffline() async {
        let data = await FeaturedCardLoader.imageData(for: sampleCards()[0]) { _ in
            throw URLError(.notConnectedToInternet)
        }

        #expect(data == nil)
    }

    @Test func imageIsNilForNonHTTPResponse() async {
        let data = await FeaturedCardLoader.imageData(for: sampleCards()[0]) { request in
            (Data([1]), URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 1, textEncodingName: nil))
        }

        #expect(data == nil)
    }

    // MARK: - Helpers

    private func sampleCards() -> [CatalogCard] {
        (1...5).map { id in
            CatalogCard(
                id: id,
                key: "card-\(id)",
                name: "Card \(id)",
                elixir: 3,
                type: "Troop",
                rarity: "Common",
                description: "",
                arena: 0
            )
        }
    }

    private func response(for url: URL, status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
