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

    var resolvedImagePath: String? {
        guard let originalPath = entry.imagePath else {
            print("❌ original imagePath is nil in UserDefaults")
            return nil
        }
        
        print("🔍 Original path from UserDefaults: \(originalPath)")
        
        // 由於 iOS App Group Container 的 UUID 在重新編譯或更新時會改變，
        // 寫死在 UserDefaults 的絕對路徑會失效，必須動態重組路徑。
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            print("❌ Failed to get containerURL for App Group: \(appGroupId)")
            return originalPath
        }
        
        let url = URL(fileURLWithPath: originalPath)
        let filename = url.lastPathComponent // 預期為 scenery_image.png
        
        // home_widget 預設會將檔案存在 app group 的 "home_widget" 子目錄中
        let actualURL = containerURL
            .appendingPathComponent("home_widget")
            .appendingPathComponent(filename)
            
        print("🔍 Dynamically reconstructed path: \(actualURL.path)")
        
        if FileManager.default.fileExists(atPath: actualURL.path) {
            print("✅ File exists at reconstructed path")
            return actualURL.path
        } else {
            print("❌ File DOES NOT exist at reconstructed path")
        }
        
        // Fallback: 檢查原本的路徑是否奇蹟般存在
        if FileManager.default.fileExists(atPath: originalPath) {
            print("✅ File exists at original path")
            return originalPath
        } else {
            print("❌ File DOES NOT exist at original path")
        }
        
        return originalPath
    }

    var uiImage: UIImage? {
        guard let path = resolvedImagePath else {
            print("❌ resolvedImagePath is nil")
            return nil
        }

        print("📷 Loading image from:", path)

        guard let image = UIImage(contentsOfFile: path) else {
            print("❌ UIImage failed to load from path: \(path)")
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

                    Text("生長中...")
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