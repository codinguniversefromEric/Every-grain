import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stage: "休耕中", weather: "晴朗", hasUnread: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stage: "秧苗期", weather: "多雲", hasUnread: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // MUST match the App Group ID configured in WidgetService.dart and Xcode
        let userDefaults = UserDefaults(suiteName: "group.com.chia.riceJourney")
        
        let stage = userDefaults?.string(forKey: "growth_stage") ?? "未知"
        let weather = userDefaults?.string(forKey: "weather") ?? "未知"
        let hasUnread = userDefaults?.bool(forKey: "has_unread_journal") ?? false

        let entry = SimpleEntry(date: Date(), stage: stage, weather: weather, hasUnread: hasUnread)
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stage: String
    let weather: String
    let hasUnread: Bool
}

struct RiceWidgetEntryView : View {
    var entry: Provider.Entry

    @ViewBuilder
    var content: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("粒粒")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
            
            Text(entry.stage)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text(entry.weather)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 160/255, green: 160/255, blue: 160/255))
            
            if entry.hasUnread {
                Text("● 阿公有信")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                    .padding(.top, 4)
            }
        }
        .widgetURL(URL(string: "ricejourney://widget"))
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(Color(red: 30/255, green: 25/255, blue: 21/255), for: .widget)
        } else {
            ZStack {
                Color(red: 30/255, green: 25/255, blue: 21/255)
                content
            }
        }
    }
}

struct RiceWidget: Widget {
    let kind: String = "RiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RiceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("粒粒農事")
        .description("在桌面靜靜陪伴您的稻田。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
