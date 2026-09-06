with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'services/widget_service.dart';", "import 'services/widget_service.dart';\nimport 'services/background_service.dart';")
content = content.replace("WidgetService.init();", "WidgetService.init();\n    BackgroundService.init();")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
