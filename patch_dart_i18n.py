import re

with open("lib/widgets/micro_simulation_overlay.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = "import '../l10n/app_localizations.dart';\n" + content
content = content.replace("請在發光處插下秧苗\\n(點擊光點)", "${AppLocalizations.of(context)!.microSimInstruction}")
content = content.replace("今日農事已畢\\n田水正好\\n去忙你的吧。", "${AppLocalizations.of(context)!.microSimCompleted}")

with open("lib/widgets/micro_simulation_overlay.dart", "w", encoding="utf-8") as f:
    f.write(content)

with open("lib/widgets/journal_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace('title = "休養生息";', 'title = loc.journalFallowTitle;')
content = content.replace('content = "田地正在休養生息。\\n我們靜待下一個節氣到來，再重新播種。";', 'content = loc.journalFallowContent;')
content = content.replace('title = "今日農事：插秧";', 'title = loc.journalPlantingTitle;')
content = content.replace('content = "田水正好，是時候把秧苗插下去了。\\n雖然辛苦，但這是一切的開始。";', 'content = loc.journalPlantingContent;')
content = content.replace('buttonText = "去田裡看看";', 'buttonText = loc.journalPlantingButton;')

with open("lib/widgets/journal_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)
