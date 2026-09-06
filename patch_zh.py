import json

with open("lib/l10n/app_zh.arb", "r", encoding="utf-8") as f:
    data = json.load(f)

data["testerLocTaoyuan"] = "📍 桃園 (北部 - 桃園3號)"
data["testerLocTainan"] = "📍 台南 (南部 - 台南11號)"
data["testerLocYilan"] = "📍 宜蘭 (東部 - 越光米)"

with open("lib/l10n/app_zh.arb", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

with open("lib/l10n/app_en.arb", "r", encoding="utf-8") as f:
    data_en = json.load(f)

data_en["testerLocTaoyuan"] = "📍 Taoyuan"
data_en["testerLocTainan"] = "📍 Tainan"
data_en["testerLocYilan"] = "📍 Yilan"

with open("lib/l10n/app_en.arb", "w", encoding="utf-8") as f:
    json.dump(data_en, f, ensure_ascii=False, indent=2)

with open("lib/l10n/app_ja.arb", "r", encoding="utf-8") as f:
    data_ja = json.load(f)

data_ja["testerLocTaoyuan"] = "📍 桃園"
data_ja["testerLocTainan"] = "📍 台南"
data_ja["testerLocYilan"] = "📍 宜蘭"

with open("lib/l10n/app_ja.arb", "w", encoding="utf-8") as f:
    json.dump(data_ja, f, ensure_ascii=False, indent=2)
