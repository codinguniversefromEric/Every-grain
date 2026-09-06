with open("ios/Runner/AppDelegate.swift", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import workmanager", "import workmanager_apple")

with open("ios/Runner/AppDelegate.swift", "w", encoding="utf-8") as f:
    f.write(content)
