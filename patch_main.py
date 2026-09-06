import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("title: !state.hasReadFirstLetter ? '阿公的信' : '農事日誌',", "title: !state.hasReadFirstLetter ? AppLocalizations.of(context)!.journalGrandpaTitle : AppLocalizations.of(context)!.journalTitle,")
content = content.replace("title: '台灣米護照',", "title: AppLocalizations.of(context)!.collectionTitle,")
content = content.replace("tooltip: '圖鑑 (Collection)',", "tooltip: AppLocalizations.of(context)!.collectionTooltip,")
content = content.replace("\"恢復真實定位\"", "AppLocalizations.of(context)!.devControlTeleportReset")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
