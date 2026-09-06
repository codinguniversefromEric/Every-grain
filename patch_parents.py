import json

en_parents = {
  "varietyTainan11Parents": "Kano-Yu 811221 / Taikeng 7",
  "varietyTaikeng9Parents": "Pei-Yu 29 / Tainung 67",
  "varietyTainung71Parents": "Kinuhikari / Taikeng 4",
  "varietyKaohsiung139Parents": "Pingtung 9 / Taichung 65",
  "varietyTaichungSen10Parents": "IR 24 / Chianung-Sen 8",
  "varietyKoshihikariParents": "Norin 22 / Norin 1",
  "varietyTaoyuan3Parents": "Taikeng 4 / Taikeng 2",
  "varietyKaohsiung147Parents": "Kaohsiung 145 / Tainung 74",
  "varietyTainung67Parents": "Kano 242 / Tainan 5",
}

ja_parents = {
  "varietyTainan11Parents": "嘉農育811221 / 台稉7号",
  "varietyTaikeng9Parents": "北育29号 / 台農67号",
  "varietyTainung71Parents": "キヌヒカリ / 台稉4号",
  "varietyKaohsiung139Parents": "屏東9号 / 台中65号",
  "varietyTaichungSen10Parents": "IR 24 / 嘉農秈8号",
  "varietyKoshihikariParents": "農林22号 / 農林1号",
  "varietyTaoyuan3Parents": "台稉4号 / 台稉2号",
  "varietyKaohsiung147Parents": "高雄145号 / 台農74号",
  "varietyTainung67Parents": "嘉農242号 / 台南5号",
}

def update_arb(lang, names):
    filepath = f"lib/l10n/app_{lang}.arb"
    with open(filepath, "r", encoding="utf-8") as f:
        arb = json.load(f)
    for k, v in names.items():
        if k in arb:
            arb[k] = v
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(arb, f, ensure_ascii=False, indent=2)

update_arb("en", en_parents)
update_arb("ja", ja_parents)

print("Parents translated.")
