import re
import json

with open("lib/models/rice_variety.dart", "r", encoding="utf-8") as f:
    content = f.read()

pattern = r"static const RiceVariety (\w+) = RiceVariety\(\s*id: '([^']+)',\s*name: '([^']+)',\s*description: '([^']+)',\s*funFact: '([^']+)',[\s\S]*?crossParents: '([^']+)',[\s\S]*?blastResistance: '([^']+)',[\s\S]*?brownPlanthopperResistance: '([^']+)',[\s\S]*?grainType: '([^']+)',"

matches = re.findall(pattern, content)

print("Found:", [m[0] for m in matches])

if len(matches) == 9:
    # We found all 9. Let's build the new dart file.
    # Replace all literal strings with empty string but preserve the structure, actually no.
    # We will change RiceVariety to NOT store these strings, but fetch them dynamically.
    pass

