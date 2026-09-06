import re

with open("android/app/src/main/AndroidManifest.xml", "r", encoding="utf-8") as f:
    content = f.read()

if "EnableImpeller" not in content:
    content = content.replace("</application>", '    <meta-data android:name="io.flutter.app.android.EnableImpeller" android:value="false" />\n    </application>')
    with open("android/app/src/main/AndroidManifest.xml", "w", encoding="utf-8") as f:
        f.write(content)
