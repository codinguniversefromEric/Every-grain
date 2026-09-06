import re

with open("lib/widgets/harvest_dialog.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("_getVarietyName(context, variety!)", "variety!.localizedName(AppLocalizations.of(context)!)")
content = content.replace("_getVarietyDesc(context, variety!)", "variety!.localizedDesc(AppLocalizations.of(context)!)")
content = content.replace("_getVarietyFact(context, variety!)", "variety!.localizedFact(AppLocalizations.of(context)!)")

# Remove the three helper methods
pattern = r"String _getVarietyName\(BuildContext context, RiceVariety v\) \{[\s\S]*?\}\n\n  String _getVarietyDesc\(BuildContext context, RiceVariety v\) \{[\s\S]*?\}\n\n  String _getVarietyFact\(BuildContext context, RiceVariety v\) \{[\s\S]*?\}"
content = re.sub(pattern, "", content)

with open("lib/widgets/harvest_dialog.dart", "w", encoding="utf-8") as f:
    f.write(content)
