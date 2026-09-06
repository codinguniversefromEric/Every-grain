import json

path = "lib/l10n/app_zh.arb"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

if "aboutRateButton" in data:
    data["aboutRateButton"] = "⭐ 給予評價"

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
