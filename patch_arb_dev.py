import json

def patch_arb(file_path, new_entries):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for k, v in new_entries.items():
        data[k] = v
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

bwa_zh = {
    "bwaTitle": "田邊土地公廟",
    "bwaDesc": "你帶著一炷香，走到田埂邊的土地公廟，祈求風調雨順。\n\n(點擊下方擲筊)",
    "bwaButton": "擲筊",
    "bwaClose": "離開",
    "bwaResultHoly": "聖筊！\n\n土地公聽到了你的祈求。\n天氣已為您修正為晴天。",
    "bwaResultLaughing": "笑筊。\n\n土地公笑了笑，沒有答應。\n或許大自然有它的安排吧。",
    "bwaResultNegative": "陰筊。\n\n土地公認為現在這樣最好。\n請順應天意。"
}
bwa_en = {
    "bwaTitle": "Earth God Shrine",
    "bwaDesc": "You brought incense to the shrine by the field, praying for good weather.\n\n(Tap below to cast moon blocks)",
    "bwaButton": "Cast Blocks",
    "bwaClose": "Leave",
    "bwaResultHoly": "Holy Blocks!\n\nThe Earth God heard your prayers.\nThe weather is now sunny.",
    "bwaResultLaughing": "Laughing Blocks.\n\nThe Earth God smiled but did not agree.\nNature has its own course.",
    "bwaResultNegative": "Negative Blocks.\n\nThe Earth God thinks it's best as it is.\nPlease follow the will of heaven."
}
bwa_ja = {
    "bwaTitle": "土地神の祠",
    "bwaDesc": "あなたは線香を持ち、畑のそばの土地神の祠に行き、天候の順調を祈りました。\n\n(下をタップして筊(ポエ)を投げる)",
    "bwaButton": "筊(ポエ)を投げる",
    "bwaClose": "離れる",
    "bwaResultHoly": "聖筊！\n\n土地神が祈りを聞き入れました。\n天候が晴れに修正されました。",
    "bwaResultLaughing": "笑筊。\n\n土地神は笑って答えませんでした。\n自然には独自の計画があるのかもしれません。",
    "bwaResultNegative": "陰筊。\n\n土地神は現状が最善だと考えています。\n天意に従ってください。"
}

dev_bilingual = {
    "testerControlsTitle": "測試員工具 (DevTools)",
    "testerControlsDesc": "快速穿梭時空，體驗完整的稻米旅程 (Time travel & testing).",
    "testerLocationTitle": "🇹🇼 1. 台灣 (Location & Varieties)",
    "testerLocationDesc": "瞬間移動會自動更新該地區的天氣與在地品種 (Updates local weather and variety).",
    "testerLocCurrent": "📍 回到目前真實位置 (Reset to Real Location)",
    "testerLocTaipei": "📍 台北 Taipei (北部 - 台稉9號)",
    "testerLocTaoyuan": "📍 桃園 Taoyuan (北部 - 桃園3號)",
    "testerLocTaichung": "📍 台中 Taichung (中部 - 台中秈10號/台農71號)",
    "testerLocTainan": "📍 台南 Tainan (南部 - 台南11號)",
    "testerLocKaohsiung": "📍 高雄 Kaohsiung (南部 - 高雄147號)",
    "testerLocYilan": "📍 宜蘭 Yilan (東部 - 越光米)",
    "testerLocTaitung": "📍 花東 Hualien/Taitung (東部 - 高雄139號)",
    "testerGlobalTitle": "✈️ 2. 海外 (Global Weather)",
    "testerLocNewYork": "🗽 紐約 New York",
    "testerLocTokyo": "🗼 東京 Tokyo",
    "testerLocParis": "🥐 巴黎 Paris",
    "testerLocSydney": "🦘 雪梨 Sydney",
    "testerLocLondon": "💂 倫敦 London",
    "testerLocCairo": "🏜️ 開羅 Cairo",
    "testerLocRio": "💃 里約 Rio",
    "testerTimeTitle": "⏳ 3. 時間 (Time Control)",
    "testerNextMonth": "快轉一個月 (Fast Forward 1 Month)",
    "testerToNight": "切換至夜晚 (Switch to Night)",
    "testerToDay": "切換至白天 (Switch to Day)",
    "testerEventsTitle": "⛈️ 4. 事件與天氣 (Events & Weather)",
    "testerForceHarvest": "強制進入收割期 (Force Harvest)",
}

# Update all three with bwa strings
patch_arb("lib/l10n/app_zh.arb", bwa_zh)
patch_arb("lib/l10n/app_en.arb", bwa_en)
patch_arb("lib/l10n/app_ja.arb", bwa_ja)

# Update all three with identical bilingual dev strings
patch_arb("lib/l10n/app_zh.arb", dev_bilingual)
patch_arb("lib/l10n/app_en.arb", dev_bilingual)
patch_arb("lib/l10n/app_ja.arb", dev_bilingual)

