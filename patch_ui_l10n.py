import re

with open("lib/visuals/collection/collection_grid.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = "import '../../utils/variety_l10n_extension.dart';\n" + content

# Replace variety.name
content = content.replace("variety.name", "variety.localizedName(loc)")
# Replace variety.description
content = content.replace("variety.description", "variety.localizedDesc(loc)")
# Replace variety.funFact
content = content.replace("variety.funFact", "variety.localizedFact(loc)")

# Replace hardcoded tariData labels
content = content.replace("_buildBackRow('日數', '${data.growthDays}天')", "_buildBackRow(loc.tariGrowthDays, '${data.growthDays}${loc.localeName == 'en' ? '' : '天'}')")
content = content.replace("_buildBackRow('千粒重', '${data.thousandGrainWeight}g')", "_buildBackRow(loc.tariWeight, '${data.thousandGrainWeight}g')")
content = content.replace("_buildBackRow('型態', data.grainType)", "_buildBackRow(loc.tariType, data.localizedGrainType(loc, widget.variety))")
content = content.replace("_buildBackRow('稻熱病', data.blastResistance)", "_buildBackRow(loc.tariBlast, data.localizedBlast(loc, widget.variety))")
content = content.replace("_buildBackRow('親本', data.crossParents)", "_buildBackRow(loc.tariParents, data.localizedParents(loc, widget.variety))")

with open("lib/visuals/collection/collection_grid.dart", "w", encoding="utf-8") as f:
    f.write(content)
