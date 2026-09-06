import json

keys = {
    "aboutRateButton": ("⭐ 給予評價 (Rate this App)", "⭐ Rate this App", "⭐ アプリを評価する")
}

def update(lang, idx):
    path = f"lib/l10n/app_{lang}.arb"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for k, v in keys.items():
        data[k] = v[idx]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

update("zh", 0)
update("en", 1)
update("ja", 2)

