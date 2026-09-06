import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("onResetField: _stateManager.plowDeadCrop,", "onResetField: _stateManager.plowDeadCrop,\n          onClearWeatherOverride: _stateManager.clearWeatherOverride,")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
