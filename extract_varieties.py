import re
import json

with open("lib/models/rice_variety.dart", "r", encoding="utf-8") as f:
    content = f.read()

# We will regex extract the varieties.
pattern = r"static const RiceVariety (\w+) = RiceVariety\(\s*id: '([^']+)',\s*name: '([^']+)',\s*description: '([^']+)',\s*funFact: '([^']+)',[\s\S]*?crossParents: '([^']+)',[\s\S]*?blastResistance: '([^']+)',\s*brownPlanthopperResistance: '([^']+)',\s*grainType: '([^']+)',"

matches = re.findall(pattern, content)

zh_dict = {}
en_dict = {}
ja_dict = {}

zh_dict["tariGrowthDays"] = "日數"
zh_dict["tariWeight"] = "千粒重"
zh_dict["tariType"] = "型態"
zh_dict["tariBlast"] = "稻熱病"
zh_dict["tariParents"] = "親本"

en_dict["tariGrowthDays"] = "Days"
en_dict["tariWeight"] = "Weight(g)"
en_dict["tariType"] = "Type"
en_dict["tariBlast"] = "Blast Res."
en_dict["tariParents"] = "Parents"

ja_dict["tariGrowthDays"] = "日数"
ja_dict["tariWeight"] = "千粒重"
ja_dict["tariType"] = "形態"
ja_dict["tariBlast"] = "いもち病"
ja_dict["tariParents"] = "交配親"

def translate_type(t):
    if t == "稉米": return "Japonica", "ジャポニカ米"
    if t == "秈米": return "Indica", "インディカ米"
    return t, t

def translate_res(r):
    res_map_en = {"極抗": "Highly Res.", "抗": "Resistant", "中抗": "Mod. Res.", "中感": "Mod. Susc.", "感": "Susceptible", "極感": "Highly Susc."}
    res_map_ja = {"極抗": "高抵抗性", "抗": "抵抗性", "中抗": "中抵抗性", "中感": "中感受性", "感": "感受性", "極感": "高感受性"}
    return res_map_en.get(r, r), res_map_ja.get(r, r)

def to_camel(s):
    parts = s.split('_')
    return parts[0] + ''.join(x.title() for x in parts[1:])

for match in matches:
    var_name, var_id, name, desc, fact, parents, blast, hopper, grain = match
    prefix = "variety" + var_name[0].upper() + var_name[1:]
    
    zh_dict[prefix + "Name"] = name
    zh_dict[prefix + "Desc"] = desc
    zh_dict[prefix + "Fact"] = fact
    zh_dict[prefix + "Parents"] = parents
    zh_dict[prefix + "Blast"] = blast
    zh_dict[prefix + "Grain"] = grain
    
    en_dict[prefix + "Name"] = name
    en_dict[prefix + "Desc"] = desc + " (English translation pending)"
    en_dict[prefix + "Fact"] = fact + " (English translation pending)"
    en_dict[prefix + "Parents"] = parents
    en_blast, ja_blast = translate_res(blast)
    en_grain, ja_grain = translate_type(grain)
    en_dict[prefix + "Blast"] = en_blast
    en_dict[prefix + "Grain"] = en_grain

    ja_dict[prefix + "Name"] = name
    ja_dict[prefix + "Desc"] = desc + " (日本語訳準備中)"
    ja_dict[prefix + "Fact"] = fact + " (日本語訳準備中)"
    ja_dict[prefix + "Parents"] = parents
    ja_dict[prefix + "Blast"] = ja_blast
    ja_dict[prefix + "Grain"] = ja_grain


for lang, data in [("zh", zh_dict), ("en", en_dict), ("ja", ja_dict)]:
    with open(f"lib/l10n/app_{lang}.arb", "r", encoding="utf-8") as f:
        arb = json.load(f)
    for k, v in data.items():
        arb[k] = v
    with open(f"lib/l10n/app_{lang}.arb", "w", encoding="utf-8") as f:
        json.dump(arb, f, ensure_ascii=False, indent=2)

print(f"Extracted {len(matches)} varieties.")
