import re
with open("lib/models/rice_variety.dart", "r", encoding="utf-8") as f:
    content = f.read()
pattern = r"static const RiceVariety (\w+) = RiceVariety\(\s*id: '([^']+)',\s*name: '([^']+)',\s*description: '([^']+)',\s*funFact: '([^']+)',[\s\S]*?crossParents: '([^']+)',[\s\S]*?blastResistance: '([^']+)',\s*brownPlanthopperResistance: '([^']+)',\s*grainType: '([^']+)',"
matches = re.findall(pattern, content)
print([m[0] for m in matches])
