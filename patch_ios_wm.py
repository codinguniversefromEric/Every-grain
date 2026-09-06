import re

with open("ios/Runner/AppDelegate.swift", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import UIKit", "import UIKit\nimport workmanager")

# Add registerTask
if "WorkmanagerPlugin" not in content:
    content = content.replace("return super.application", "WorkmanagerPlugin.registerTask(withIdentifier: \"widget_update\")\n    return super.application")

with open("ios/Runner/AppDelegate.swift", "w", encoding="utf-8") as f:
    f.write(content)

# Now Info.plist
with open("ios/Runner/Info.plist", "r", encoding="utf-8") as f:
    plist = f.read()

if "BGTaskSchedulerPermittedIdentifiers" not in plist:
    insert_str = """
	<key>BGTaskSchedulerPermittedIdentifiers</key>
	<array>
		<string>widget_update</string>
	</array>
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
		<string>processing</string>
	</array>"""
    plist = plist.replace("<dict>", "<dict>" + insert_str, 1)

with open("ios/Runner/Info.plist", "w", encoding="utf-8") as f:
    f.write(plist)

