import WidgetKit
import SwiftUI

private let appGroupId = "group.com.chia.riceJourney"

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            imagePath: nil,
            contextName: "placeholder"
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let imagePath = userDefaults?.string(forKey: "scenery_image")

        let entry = SimpleEntry(
            date: Date(),
            imagePath: imagePath,
            contextName: context.isPreview ? "preview" : "snapshot"
        )

        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let imagePath = userDefaults?.string(forKey: "scenery_image")

        let entry = SimpleEntry(
            date: Date(),
            imagePath: imagePath,
            contextName: "timeline"
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
    let contextName: String
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
        let filename = url.lastPathComponent
        
        let actualURL = containerURL
            .appendingPathComponent("home_widget")
            .appendingPathComponent(filename)
            
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

    // 將診斷資訊顯示在畫面上，讓我們一眼看出 Small 與 Medium 的差異
    var diagnosticOverlay: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Ctx: \(entry.contextName)")
            Text("Fam: \(family == .systemSmall ? "Small" : "Medium")")
            Text("Path: \(entry.imagePath != nil ? "OK" : "NIL")")
            
            if let path = resolvedImagePath {
                let exists = FileManager.default.fileExists(atPath: path)
                Text("File: \(exists ? "YES" : "NO")")
                
                if let img = UIImage(contentsOfFile: path) {
                    Text("Img: \(Int(img.size.width))x\(Int(img.size.height))")
                } else {
                    Text("Img: LOAD FAIL")
                }
            }
        }
        .font(.system(size: 9, weight: .bold))
        .foregroundColor(.green)
        .padding(4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(4)
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            Color.black

            if let image = uiImage {
                // 套用使用者建議的 GeometryReader + scaledToFill 測試
                GeometryReader { proxy in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .clipped()
                }
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
            
            // 顯示診斷浮水印 (左上角)
            VStack {
                HStack {
                    diagnosticOverlay
                    Spacer()
                }
                Spacer()
            }
            .padding(8)
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