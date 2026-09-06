import json

def patch_arb(file_path, new_entries):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for k, v in new_entries.items():
        data[k] = v
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

zh_entries = {
    "collectionTitle": "台灣米護照",
    "collectionTooltip": "圖鑑 (Collection)",
    "collectionSourceText": "學術數據授權 / 資料來源：\n農業部農業試驗所 (TARI) - 水稻品種資訊系統",
    "journalTitle": "農事日誌",
    "journalTooltip": "日誌 (Journal)",
    "journalGrandpaTitle": "阿公的信",
    "journalGrandpaContent": "孩子，歡迎來到這片田。\n\n這裡不需要你每天辛苦登入除草，也不需要你花錢買肥料。\n你只需要偶爾看著它，聽聽風聲、聽聽蟲鳴。\n\n每一粒米都是時間的餽贈。去感受這片土地的呼吸吧。",
    "journalGrandpaButton": "我明白了",
    "journalDeadTitle": "天有不測風雲",
    "journalDeadContent": "極端的氣候讓植物枯萎了。\n\n這就是務農的無奈，大自然有它自己的脾氣。\n我們只能認命翻土，等待下個節氣到來，重新來過。",
    "journalDeadButton": "認命翻土",
    "journalNothingContent": "今天田裡沒什麼特別的事，稻子正安靜地生長著。\n\n「看天田，隨遇而安。」",
    "journalPrayButton": "氣象局報錯了，去向土地公抱怨",
    "journalCloseButton": "關閉",
    "journalFallowTitle": "休耕中",
    "journalFallowContent": "土地正在休息，等待下一個節氣的到來。\n這段時間，您可以到處走走，看看不一樣的風景。",
    "devControlTeleportReset": "恢復真實定位",
    "devControlTeleportResetDesc": "您目前正在模擬其他地區，氣象與品種已強制鎖定"
}

en_entries = {
    "collectionTitle": "Rice Passport",
    "collectionTooltip": "Collection",
    "collectionSourceText": "Academic Data Licensed from:\nTaiwan Agricultural Research Institute (TARI)",
    "journalTitle": "Farm Journal",
    "journalTooltip": "Journal",
    "journalGrandpaTitle": "A Letter from Grandpa",
    "journalGrandpaContent": "Welcome to the field, my child.\n\nYou don't need to log in every day to weed, nor buy fertilizer.\nJust look at it occasionally, listen to the wind and bugs.\n\nEvery grain is a gift of time. Feel the breath of this land.",
    "journalGrandpaButton": "I understand",
    "journalDeadTitle": "Unexpected Weather",
    "journalDeadContent": "Extreme climate has caused the plants to wither.\n\nThis is the helplessness of farming; nature has its temper.\nWe can only accept it, plow the soil, and wait for the next solar term to start over.",
    "journalDeadButton": "Plow the soil",
    "journalNothingContent": "Nothing special in the field today, the rice is growing quietly.\n\n\"Let nature take its course.\"",
    "journalPrayButton": "Weather app is wrong, pray to Earth God",
    "journalCloseButton": "Close",
    "journalFallowTitle": "Fallow Period",
    "journalFallowContent": "The land is resting, waiting for the next solar term.\nTake a walk around and see different sceneries.",
    "devControlTeleportReset": "Reset to Real Location",
    "devControlTeleportResetDesc": "You are simulating another region. Weather and variety are overridden."
}

ja_entries = {
    "collectionTitle": "台湾米パスポート",
    "collectionTooltip": "図鑑 (Collection)",
    "collectionSourceText": "学術データライセンス提供：\n台湾農業試験所 (TARI)",
    "journalTitle": "農作業日誌",
    "journalTooltip": "日誌 (Journal)",
    "journalGrandpaTitle": "おじいちゃんからの手紙",
    "journalGrandpaContent": "この畑へようこそ。\n\n毎日ログインして草むしりする必要も、肥料を買う必要もありません。\nただ時々見て、風の音や虫の声を聞いてください。\n\n一粒一粒がお米は時間の贈り物です。この土地の呼吸を感じてください。",
    "journalGrandpaButton": "わかりました",
    "journalDeadTitle": "不測の事態",
    "journalDeadContent": "極端な気候により植物が枯れてしまいました。\n\nこれが農業の無力さです。自然には独自の気まぐれがあります。\n諦めて土を耕し、次の二十四節気を待ってやり直すしかありません。",
    "journalDeadButton": "土を耕す",
    "journalNothingContent": "今日は畑に特別なことはなく、稲は静かに成長しています。\n\n「天に任せる」",
    "journalPrayButton": "天気予報が間違っている、土地神様に文句を言う",
    "journalCloseButton": "閉じる",
    "journalFallowTitle": "休耕中",
    "journalFallowContent": "土地は休んでおり、次の二十四節気を待っています。\n少し歩き回って、違う景色を見てみましょう。",
    "devControlTeleportReset": "現在の位置に戻る",
    "devControlTeleportResetDesc": "現在他の地域をシミュレートしています。天候と品種は上書きされています。"
}

patch_arb("lib/l10n/app_zh.arb", zh_entries)
patch_arb("lib/l10n/app_en.arb", en_entries)
patch_arb("lib/l10n/app_ja.arb", ja_entries)

