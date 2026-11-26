import SwiftUI
import UIKit
import WidgetKit

struct CardWidgetEntry: TimelineEntry {
    let date: Date
    let card: CatalogCard?
    let errorMessage: String?
    /// Image de la carte, déjà téléchargée : un widget ne peut pas charger
    /// d'image lui-même (AsyncImage y reste bloqué sur le placeholder).
    var image: UIImage? = nil
}

struct CardWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CardWidgetEntry {
        CardWidgetEntry(date: .now, card: CatalogCard.preview, errorMessage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CardWidgetEntry) -> Void) {
        if context.isPreview {
            completion(CardWidgetEntry(date: .now, card: CatalogCard.preview, errorMessage: nil))
        } else {
            Task {
                completion(await makeEntry())
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CardWidgetEntry>) -> Void) {
        Task {
            let entry = await makeEntry()
            let nextUpdate = Date.now.addingTimeInterval(8 * 60 * 60)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func makeEntry() async -> CardWidgetEntry {
        let result = await FeaturedCardLoader.load(on: .now)
        guard let card = result.card else {
            return CardWidgetEntry(date: .now, card: nil, errorMessage: result.errorMessage)
        }
        let data = await FeaturedCardLoader.imageData(for: card)
        let image = await Self.thumbnail(from: data)
        return CardWidgetEntry(date: .now, card: card, errorMessage: nil, image: image)
    }

    /// Réduit l'image pour rester sous la limite de mémoire des widgets.
    /// `nil` si le téléchargement a échoué : le widget affiche l'icône de remplacement.
    private static func thumbnail(from data: Data?) async -> UIImage? {
        guard let data, let image = UIImage(data: data) else { return nil }
        return await image.byPreparingThumbnail(ofSize: CGSize(width: 120, height: 144)) ?? image
    }
}

struct CardWidgetView: View {
    var entry: CardWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CARD OF THE DAY")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            if let card = entry.card {
                let elixir = card.elixir.map { String($0) } ?? "—"
                HStack(spacing: 10) {
                    Group {
                        if let image = entry.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "rectangle.portrait")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text("\(card.rarity.capitalized) · \(elixir) elixir")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            } else {
                Text(entry.errorMessage ?? "Loading cards…")
                    .font(.caption)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CardWidget: Widget {
    let kind = "CardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CardWidgetProvider()) { entry in
            CardWidgetView(entry: entry)
        }
        .configurationDisplayName("Card of the Day")
        .description("See a Clash Royale card and its elixir cost.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct CardWidgetBundle: WidgetBundle {
    var body: some Widget {
        CardWidget()
    }
}
