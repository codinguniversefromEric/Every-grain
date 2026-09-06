with open("lib/widgets/widget_scenery_snapshot.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("width: 800,", "width: 400,")
content = content.replace("height: 800,", "height: 400,")
content = content.replace("height: 200, // Thick ground for 800x800", "height: 100, // Thick ground")
content = content.replace("height: 400,", "height: 200,")

with open("lib/widgets/widget_scenery_snapshot.dart", "w", encoding="utf-8") as f:
    f.write(content)
