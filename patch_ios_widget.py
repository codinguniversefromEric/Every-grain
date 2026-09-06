import re

with open("ios/RiceWidget/RiceWidget.swift", "r", encoding="utf-8") as f:
    content = f.read()

# Replace the inner content layout
new_content_code = """
    @ViewBuilder
    var content: some View {
        ZStack {
            Color.black
            
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
        .widgetURL(URL(string: "ricejourney://widget"))
    }
"""

content = re.sub(r'@ViewBuilder\s*var content: some View \{.*?\n    \}', new_content_code.strip(), content, flags=re.DOTALL)

# Replace the body layout
new_body_code = """
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(Color.black, for: .widget)
        } else {
            content
        }
    }
"""
content = re.sub(r'var body: some View \{.*?\n    \}', new_body_code.strip(), content, flags=re.DOTALL)

with open("ios/RiceWidget/RiceWidget.swift", "w", encoding="utf-8") as f:
    f.write(content)
