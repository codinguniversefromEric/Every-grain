import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imagePath: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imagePath: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.chia.riceJourney")
        let imagePath = userDefaults?.string(forKey: "scenery_image")
        
        let entry = SimpleEntry(date: Date(), imagePath: imagePath)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imagePath: String?
}

struct RiceWidgetEntryView : View {
    var entry: Provider.Entry
    
    var uiImage: UIImage? {
        if let path = entry.imagePath, let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            // Inner frame / bevel
            Color(red: 30/255, green: 25/255, blue: 21/255) // #1E1915
            
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Text("生長中...")
                    .unredacted()
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                    .font(.system(size: 14))
            }
        }
        .padding(2)
        .widgetURL(URL(string: "ricejourney://widget"))
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(Color(red: 61/255, green: 28/255, blue: 4/255), for: .widget)
                .padding(8) // Thick wooden outer frame effect
                .background(Color(red: 61/255, green: 28/255, blue: 4/255))
        } else {
            ZStack {
                Color(red: 61/255, green: 28/255, blue: 4/255)
                content.padding(8)
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
        // In iOS 15/16, this removes default padding
        .contentMarginsDisabledIfAvailable() 
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 15.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
