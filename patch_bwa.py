import re

with open("lib/widgets/bwa_bwei_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add import
if "import '../l10n/app_localizations.dart';" not in content:
    content = content.replace("import '../services/state_manager.dart';", "import '../services/state_manager.dart';\nimport '../l10n/app_localizations.dart';")

content = content.replace('String _resultText = "";', 'String _resultText = "";\n  late AppLocalizations loc;')

content = content.replace('Widget build(BuildContext context) {', 'Widget build(BuildContext context) {\n    loc = AppLocalizations.of(context)!;')

# Replace strings
content = content.replace('          _resultText = "聖筊！\\n\\n土地公聽到了你的祈求。\\n天氣已為您修正為晴天。";', '          _resultText = loc.bwaResultHoly;')
content = content.replace('          _resultText = "笑筊。\\n\\n土地公笑了笑，沒有答應。\\n或許大自然有它的安排吧。";', '          _resultText = loc.bwaResultLaughing;')
content = content.replace('          _resultText = "陰筊。\\n\\n土地公認為現在這樣最好。\\n請順應天意。";', '          _resultText = loc.bwaResultNegative;')
content = content.replace('"田邊土地公廟"', 'loc.bwaTitle')
content = content.replace('_tossed ? _resultText : "你帶著一炷香，走到田埂邊的土地公廟，祈求風調雨順。\\n\\n(點擊下方擲筊)"', '_tossed ? _resultText : loc.bwaDesc')
content = content.replace('"擲筊"', 'loc.bwaButton')
content = content.replace('"離開"', 'loc.bwaClose')

with open("lib/widgets/bwa_bwei_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)

