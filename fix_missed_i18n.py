import json

keys = {
  "microSimInstruction": ("請在發光處插下秧苗\n(點擊光點)", "Please plant seedlings at the glowing spots\n(Tap the lights)", "光っている場所に苗を植えてください\n（光をタップ）"),
  "microSimCompleted": ("今日農事已畢\n田水正好\n去忙你的吧。", "Today's farming is done.\nThe water is just right.\nGo back to your day.", "今日の農作業は終わりました。\n水の加減もちょうど良いです。\n日常に戻りましょう。"),
  "journalFallowTitle": ("休養生息", "Fallow Rest", "休閑（きゅうかん）"),
  "journalFallowContent": ("田地正在休養生息。\n我們靜待下一個節氣到來，再重新播種。", "The field is resting.\nWe wait for the next solar term to plant again.", "田んぼは休養中です。\n次の節気が来て、再び種を蒔くのを待ちましょう。"),
  "journalPlantingTitle": ("今日農事：插秧", "Today's Task: Planting", "今日の農作業：田植え"),
  "journalPlantingContent": ("田水正好，是時候把秧苗插下去了。\n雖然辛苦，但這是一切的開始。", "The water is perfect, it's time to plant the seedlings.\nIt's hard work, but it's the beginning of everything.", "水の加減がちょうど良く、苗を植える時期です。\n大変ですが、ここから全てが始まります。"),
  "journalPlantingButton": ("去田裡看看", "Go to the field", "田んぼへ行く")
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
