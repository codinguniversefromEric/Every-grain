import re

with open("lib/widgets/harvest_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = "import '../utils/variety_l10n_extension.dart';\n" + content

# Remove the two manual helper methods completely and replace their usages.
# The methods are _getVarietyName and _getVarietyDesc.
# Let's just find and replace the usages and we can leave the unused methods or delete them.
content = content.replace("_getVarietyName(context, state.currentVariety)", "state.currentVariety.localizedName(AppLocalizations.of(context)!)")
content = content.replace("_getVarietyDesc(context, state.currentVariety)", "state.currentVariety.localizedDesc(AppLocalizations.of(context)!)")

with open("lib/widgets/harvest_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)
