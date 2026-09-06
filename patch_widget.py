with open("ios/RiceWidget/RiceWidget.swift", "r", encoding="utf-8") as f:
    content = f.read()

old_get_snapshot = """    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imagePath: nil)
        completion(entry)
    }"""

new_get_snapshot = """    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.chia.riceJourney")
        let imagePath = userDefaults?.string(forKey: "scenery_image")
        let entry = SimpleEntry(date: Date(), imagePath: imagePath)
        completion(entry)
    }"""

content = content.replace(old_get_snapshot, new_get_snapshot)

with open("ios/RiceWidget/RiceWidget.swift", "w", encoding="utf-8") as f:
    f.write(content)
