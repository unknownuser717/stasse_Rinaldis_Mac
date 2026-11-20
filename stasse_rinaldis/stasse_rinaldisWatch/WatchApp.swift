import SwiftUI

@main
struct StasseWatchApp: App {
    @StateObject private var catalog = WatchCatalogModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                WatchCardList(catalog: catalog)
                WatchStats(catalog: catalog)
            }
            .tabViewStyle(.page)
            .task { await catalog.load() }
        }
    }
}

@MainActor
final class WatchCatalogModel: ObservableObject {
    @Published private(set) var cards: [CatalogCard] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    var averageElixir: Double {
        let costs = cards.compactMap(\.elixir)
        guard !costs.isEmpty else { return 0 }
        return Double(costs.reduce(0, +)) / Double(costs.count)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            cards = try await CardCatalog.load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct WatchCardList: View {
    @ObservedObject var catalog: WatchCatalogModel

    var body: some View {
        NavigationStack {
            Group {
                if catalog.isLoading && catalog.cards.isEmpty {
                    ProgressView("Loading cards")
                } else if let error = catalog.errorMessage, catalog.cards.isEmpty {
                    ContentUnavailableView {
                        Label("Cards unavailable", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try again") {
                            Task { await catalog.load() }
                        }
                    }
                } else {
                    List(catalog.cards) { card in
                        NavigationLink {
                            WatchCardDetail(card: card)
                        } label: {
                            HStack {
                                Text(card.name)
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(card.elixir.map { String($0) } ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cards")
        }
    }
}

private struct WatchCardDetail: View {
    let card: CatalogCard

    var body: some View {
        List {
            if let imageURL = card.imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 100)
                .frame(maxWidth: .infinity)
            }
            LabeledContent("Rarity", value: card.rarity.capitalized)
            LabeledContent("Elixir", value: card.elixir.map { String($0) } ?? "—")
            LabeledContent("Type", value: card.type)
            Text(card.description)
                .font(.footnote)
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WatchStats: View {
    @ObservedObject var catalog: WatchCatalogModel
    private let rarities = ["Common", "Rare", "Epic", "Legendary", "Champion"]

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("Cards", value: "\(catalog.cards.count)")
                LabeledContent("Avg. elixir", value: String(format: "%.1f", catalog.averageElixir))
                Section("By rarity") {
                    ForEach(rarities, id: \.self) { rarity in
                        let count = catalog.cards.filter { $0.rarity.caseInsensitiveCompare(rarity) == .orderedSame }.count
                        LabeledContent(rarity, value: "\(count)")
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}
