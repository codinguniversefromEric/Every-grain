import json

en_names = {
  "varietyTainan11Name": "Tainan 11",
  "varietyTaikeng9Name": "Taikeng 9",
  "varietyTainung71Name": "Tainung 71",
  "varietyKaohsiung139Name": "Kaohsiung 139",
  "varietyTaoyuan3Name": "Taoyuan 3",
  "varietyTaichungSen10Name": "Taichung Sen 10",
  "varietyKaohsiung147Name": "Kaohsiung 147",
  "varietyKoshihikariName": "Koshihikari",
  "varietyTainung67Name": "Tainung 67",
}

ja_names = {
  "varietyTainan11Name": "台南11号",
  "varietyTaikeng9Name": "台稉9号",
  "varietyTainung71Name": "台農71号",
  "varietyKaohsiung139Name": "高雄139号",
  "varietyTaoyuan3Name": "桃園3号",
  "varietyTaichungSen10Name": "台中秈10号",
  "varietyKaohsiung147Name": "高雄147号",
  "varietyKoshihikariName": "コシヒカリ",
  "varietyTainung67Name": "台農67号",
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

update_arb("en", en_names)
update_arb("ja", ja_names)

print("Names translated.")
