import WidgetKit
import SwiftUI

private let appGroupId = "group.com.chia.riceJourney"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imagePath: nil, contextName: "placeholder", refreshId: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let imagePath = userDefaults?.string(forKey: "scenery_image")
        let entry = SimpleEntry(date: Date(), imagePath: imagePath, contextName: context.isPreview ? "preview" : "snapshot", refreshId: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let imagePath = userDefaults?.string(forKey: "scenery_image")
        
        // 加入一個唯一識別碼 (UUID)，強制 WidgetKit 知道這是一個全新的 Entry 狀態，避免 View 快取
        let entry = SimpleEntry(
            date: Date(),
            imagePath: imagePath,
            contextName: "timeline",
            refreshId: UUID().uuidString
        )
        
        // 改用 .never：完全由 Flutter 端的 HomeWidget.updateWidget() 來控制更新
        // 避免系統每小時自動喚醒消耗 WidgetKit 嚴格的每日更新配額 (Budget)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imagePath: String?
    let contextName: String
    let refreshId: String? // 用於 Cache Busting
}

struct RiceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var resolvedImagePath: String? {
        guard let originalPath = entry.imagePath else { return nil }
        
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            return originalPath
        }
        
        let url = URL(fileURLWithPath: originalPath)
        let actualURL = containerURL
            .appendingPathComponent("home_widget")
            .appendingPathComponent(url.lastPathComponent)
            
        if FileManager.default.fileExists(atPath: actualURL.path) {
            return actualURL.path
        }
        
        if FileManager.default.fileExists(atPath: originalPath) {
            return originalPath
        }
        
        return originalPath
    }

    var uiImage: UIImage? {
        guard let path = resolvedImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            Color.black

            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .unredacted()
            }
            
            VStack(alignment: .leading) {
                Text("Ctx: \(entry.contextName)")
                Text("Path: \(entry.imagePath != nil ? "YES" : "NIL")")
                if let rp = resolvedImagePath {
                    let exists = FileManager.default.fileExists(atPath: rp)
                    Text("File: \(exists ? "YES" : "NO")")
                    if exists {
                        Text("Size: \(getFileSize(path: rp))b")
                    }
                }
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.green)
            .padding(4)
            .background(Color.black.opacity(0.5))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .unredacted()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func getFileSize(path: String) -> UInt64 {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            return attr[.size] as? UInt64 ?? 0
        } catch {
            return 0
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