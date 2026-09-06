import re

with open("android/app/src/main/AndroidManifest.xml", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("io.flutter.app.android.EnableImpeller", "io.flutter.embedding.android.EnableImpeller")

with open("android/app/src/main/AndroidManifest.xml", "w", encoding="utf-8") as f:
    f.write(content)
