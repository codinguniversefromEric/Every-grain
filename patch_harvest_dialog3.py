import re

with open("lib/widgets/harvest_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = "import '../utils/variety_l10n_extension.dart';\n" + content

content = content.replace("_getVarietyName(context, variety!)", "variety!.localizedName(AppLocalizations.of(context)!)")
content = content.replace("_getVarietyDesc(context, variety!)", "variety!.localizedDesc(AppLocalizations.of(context)!)")
content = content.replace("_getVarietyFact(context, variety!)", "variety!.localizedFact(AppLocalizations.of(context)!)")

with open("lib/widgets/harvest_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)
