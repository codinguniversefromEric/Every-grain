import re

with open("lib/widgets/journal_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace('String title = "農事日誌";', 'String title = loc.journalTitle;')
content = content.replace('String content = "";', 'String content = "";')
content = content.replace('String buttonText = "關閉";', 'String buttonText = loc.journalCloseButton;')
content = content.replace('title = "阿公的信";', 'title = loc.journalGrandpaTitle;')
content = content.replace('content = "孩子，歡迎來到這片田。\\n\\n這裡不需要你每天辛苦登入除草，也不需要你花錢買肥料。\\n你只需要偶爾看著它，聽聽風聲、聽聽蟲鳴。\\n\\n每一粒米都是時間的餽贈。去感受這片土地的呼吸吧。";', 'content = loc.journalGrandpaContent;')
content = content.replace('buttonText = "我明白了";', 'buttonText = loc.journalGrandpaButton;')
content = content.replace('title = "天有不測風雲";', 'title = loc.journalDeadTitle;')
content = content.replace('content = "極端的氣候讓植物枯萎了。\\n\\n這就是務農的無奈，大自然有它自己的脾氣。\\n我們只能認命翻土，等待下個節氣到來，重新來過。";', 'content = loc.journalDeadContent;')
content = content.replace('buttonText = "認命翻土";', 'buttonText = loc.journalDeadButton;')
content = content.replace('content = "今天田裡沒什麼特別的事，稻子正安靜地生長著。\\n\\n「看天田，隨遇而安。」";', 'content = loc.journalNothingContent;')
content = content.replace('"氣象局報錯了，去向土地公抱怨"', 'loc.journalPrayButton')

# Also import AppLocalizations
if "import '../l10n/app_localizations.dart';" not in content:
    content = content.replace("import '../models/field_state.dart';", "import '../models/field_state.dart';\nimport '../l10n/app_localizations.dart';")

# Add loc variable inside build method
content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final loc = AppLocalizations.of(context)!;")

with open("lib/widgets/journal_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)

with open("lib/visuals/collection/collection_grid.dart", "r", encoding="utf-8") as f:
    content2 = f.read()

if "import '../../l10n/app_localizations.dart';" not in content2:
    content2 = content2.replace("import '../../models/rice_variety.dart';", "import '../../models/rice_variety.dart';\nimport '../../l10n/app_localizations.dart';")

content2 = content2.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final loc = AppLocalizations.of(context)!;")
content2 = content2.replace("'學術數據授權 / 資料來源：\\n農業部農業試驗所 (TARI) - 水稻品種資訊系統'", "loc.collectionSourceText")

with open("lib/visuals/collection/collection_grid.dart", "w", encoding="utf-8") as f:
    f.write(content2)

