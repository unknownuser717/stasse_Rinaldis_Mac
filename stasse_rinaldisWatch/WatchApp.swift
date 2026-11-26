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

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("Cards", value: "\(catalog.cards.count)")
                LabeledContent("Avg. elixir", value: String(format: "%.1f", catalog.averageElixir))
                Section("By rarity") {
                    ForEach(WatchCatalogModel.rarities, id: \.self) { rarity in
                        LabeledContent(rarity, value: "\(catalog.count(rarity: rarity))")
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}
