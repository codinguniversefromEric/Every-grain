with open("ios/Runner/AppDelegate.swift", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    'WorkmanagerPlugin.registerTask(withIdentifier: "widget_update")',
    '''WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "widget_update")'''
)

with open("ios/Runner/AppDelegate.swift", "w", encoding="utf-8") as f:
    f.write(content)
