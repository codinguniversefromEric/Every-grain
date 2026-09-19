import WidgetKit
import SwiftUI

private let appGroupId = "group.com.chia.riceJourney"

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            imagePath: nil
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {
        let userDefaults = UserDefaults(suiteName: appGroupId)

        let imagePath = userDefaults?.string(
            forKey: "scenery_image"
        )

        print("🍚 Widget Snapshot")
        print("imagePath:", imagePath ?? "nil")

        let entry = SimpleEntry(
            date: Date(),
            imagePath: imagePath
        )

        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let userDefaults = UserDefaults(suiteName: appGroupId)

        let imagePath = userDefaults?.string(
            forKey: "scenery_image"
        )

        print("🍚 Widget Timeline")
        print("imagePath:", imagePath ?? "nil")

        let entry = SimpleEntry(
            date: Date(),
            imagePath: imagePath
        )

        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date()
        )!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )

        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imagePath: String?
}

struct RiceWidgetEntryView: View {

    var entry: Provider.Entry

    var uiImage: UIImage? {
        guard let path = entry.imagePath else {
            print("❌ imagePath is nil")
            return nil
        }

        print("📷 Loading image:", path)

        guard FileManager.default.fileExists(atPath: path) else {
            print("❌ File does not exist:", path)
            return nil
        }

        guard let image = UIImage(contentsOfFile: path) else {
            print("❌ UIImage failed to load:", path)
            return nil
        }

        print("✅ Image loaded successfully")

        return image
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            Color.black

            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))

                    Text("等待稻田")
                        .font(.system(size: 14))
                }
                .foregroundColor(
                    Color(
                        red: 212 / 255,
                        green: 175 / 255,
                        blue: 55 / 255
                    )
                )
            }
        }
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(
                    Color.black,
                    for: .widget
                )
        } else {
            content
        }
    }
}

struct RiceWidget: Widget {

    let kind: String = "RiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            RiceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("粒粒農事")
        .description("在桌面靜靜陪伴您的稻田。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        .contentMarginsDisabledIfAvailable()
    }
}

extension WidgetConfiguration {

    func contentMarginsDisabledIfAvailable()
        -> some WidgetConfiguration {

        if #available(iOS 15.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}