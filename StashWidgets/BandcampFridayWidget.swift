import SwiftUI
import WidgetKit

struct BandcampFridayProvider: TimelineProvider {
    func placeholder(in _: Context) -> BandcampFridayEntry {
        BandcampFridayEntry(date: Date(), queueCount: 0, nextBandcampFriday: nil)
    }

    func getSnapshot(in _: Context, completion: @escaping (BandcampFridayEntry) -> Void) {
        let entry = BandcampFridayEntry(
            date: Date(),
            queueCount: 4,
            nextBandcampFriday: nextBandcampFriday()
        )
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<BandcampFridayEntry>) -> Void) {
        let entry = BandcampFridayEntry(
            date: Date(),
            queueCount: 0, // Will be fetched from shared data in Phase 6
            nextBandcampFriday: nextBandcampFriday()
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func nextBandcampFriday() -> Date? {
        let bandcampFridays2026: [DateComponents] = [
            DateComponents(year: 2026, month: 2, day: 6),
            DateComponents(year: 2026, month: 3, day: 6),
            DateComponents(year: 2026, month: 5, day: 1),
            DateComponents(year: 2026, month: 8, day: 7),
            DateComponents(year: 2026, month: 9, day: 4),
            DateComponents(year: 2026, month: 10, day: 2),
            DateComponents(year: 2026, month: 11, day: 6),
            DateComponents(year: 2026, month: 12, day: 4)
        ]

        let calendar = Calendar.current
        let now = Date()

        for components in bandcampFridays2026 {
            if let date = calendar.date(from: components), date > now {
                return date
            }
        }

        return nil
    }
}

struct BandcampFridayEntry: TimelineEntry {
    let date: Date
    let queueCount: Int
    let nextBandcampFriday: Date?
}

struct BandcampFridayWidgetEntryView: View {
    var entry: BandcampFridayProvider.Entry
    @Environment(\.widgetFamily)
    var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundStyle(.pink)
                Text("Bandcamp Friday")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            if let nextFriday = entry.nextBandcampFriday {
                Text(nextFriday, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if self.entry.queueCount > 0 {
                    Text("\(self.entry.queueCount) items in queue")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No upcoming dates")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct BandcampFridayWidget: Widget {
    let kind = "BandcampFridayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: self.kind, provider: BandcampFridayProvider()) { entry in
            BandcampFridayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bandcamp Friday")
        .description("Track your Bandcamp Friday purchase queue")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BandcampFridayWidget()
} timeline: {
    BandcampFridayEntry(
        date: .now,
        queueCount: 4,
        nextBandcampFriday: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 6))
    )
}
