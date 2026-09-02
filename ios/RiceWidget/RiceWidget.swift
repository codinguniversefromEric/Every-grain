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
        let userDefaults = UserDefaults(suiteName: "group.com.chia.riceJourney")
        
        let stage = userDefaults?.string(forKey: "growth_stage") ?? "未知"
        let weather = userDefaults?.string(forKey: "weather") ?? "晴朗"
        let hasUnread = userDefaults?.bool(forKey: "has_unread_journal") ?? false

        let entry = SimpleEntry(date: Date(), stage: stage, weather: weather, hasUnread: hasUnread)
        
        // Update widget every hour to reflect sky color changes automatically
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
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
    
    // Dynamic Sky Logic
    var isLightSky: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        if entry.weather == "有雨" || entry.weather == "雷雨" { return false }
        if entry.weather == "多雲" { return true }
        // Clear sky
        return hour >= 6 && hour <= 16
    }
    
    var skyGradient: LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if entry.weather == "多雲" {
            return LinearGradient(colors: [Color(red: 117/255, green: 127/255, blue: 154/255), Color(red: 215/255, green: 221/255, blue: 232/255)], startPoint: .top, endPoint: .bottom)
        } else if entry.weather == "有雨" || entry.weather == "雷雨" {
            return LinearGradient(colors: [Color(red: 55/255, green: 59/255, blue: 68/255), Color(red: 66/255, green: 134/255, blue: 244/255)], startPoint: .top, endPoint: .bottom)
        } else {
            // Clear sky
            if hour >= 6 && hour <= 16 {
                // Day
                return LinearGradient(colors: [Color(red: 106/255, green: 183/255, blue: 230/255), Color(red: 162/255, green: 217/255, blue: 245/255)], startPoint: .top, endPoint: .bottom)
            } else if hour >= 17 && hour <= 18 {
                // Sunset
                return LinearGradient(colors: [Color(red: 255/255, green: 126/255, blue: 95/255), Color(red: 254/255, green: 180/255, blue: 123/255)], startPoint: .top, endPoint: .bottom)
            } else {
                // Night
                return LinearGradient(colors: [Color(red: 15/255, green: 32/255, blue: 39/255), Color(red: 32/255, green: 58/255, blue: 67/255), Color(red: 44/255, green: 83/255, blue: 100/255)], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("粒粒")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
            
            Text(entry.stage)
                .font(.system(size: 16))
                .foregroundColor(isLightSky ? Color(red: 34/255, green: 34/255, blue: 34/255) : .white)
            
            Text(entry.weather)
                .font(.system(size: 14))
                .foregroundColor(isLightSky ? Color(red: 68/255, green: 68/255, blue: 68/255) : Color(red: 160/255, green: 160/255, blue: 160/255))
            
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
            content.containerBackground(skyGradient, for: .widget)
        } else {
            ZStack {
                skyGradient
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
