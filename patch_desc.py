import json

en_desc = {
  "varietyTainan11Desc": "The most widely planted variety in Taiwan. Plump grains and high yield make it the staple white rice for the whole nation.",
  "varietyTainan11Fact": "Knowledge: It boasts excellent pest resistance and stable yield, making it the reliable backbone of Taiwan's agriculture.",
  "varietyKaohsiung139Desc": "The flagship variety of eastern Taiwan. Though the grains have a cloudy center, its taste and texture are exceptional.",
  "varietyKaohsiung139Fact": "Knowledge: Often affectionately called 'Ugly Beauty' by farmers. Its outstanding flavor is nurtured by the pristine waters of eastern Taiwan.",
  "varietyTainung71Desc": "A famous variety from central Taiwan, emitting a rich taro aroma when cooked. Short, plump grains with a sticky texture.",
  "varietyTainung71Fact": "Knowledge: Named 'Yiquan' to honor Dr. Kuo Yi-Chuan, who devoted his life to developing this variety but passed away before its release.",
  "varietyTaikeng9Desc": "A premium variety common in northern Taiwan. It retains its chewy texture even when cold, making it perfect for top-tier sushi and onigiri.",
  "varietyTaikeng9Fact": "Knowledge: Many major convenience store chains strictly specify Taikeng 9 for their premium rice balls!",
  "varietyTaichungSen10Desc": "Taiwan's most widely grown and most delicious Indica (long-grain) rice. High in fiber, low in starch, fluffy and non-sticky.",
  "varietyTaichungSen10Fact": "Knowledge: It completely shattered the stereotype that Indica rice tastes bad, becoming a staple in both vegetarian diets and fried rice dishes.",
  "varietyKoshihikariDesc": "A legendary super variety originating from Japan. Translucent grains with strong stickiness and an unmatched texture, though very difficult to cultivate.",
  "varietyKoshihikariFact": "Knowledge: Taiwan's climate is typically too hot for it, but farmers in Chishang have managed to cultivate it successfully through exceptional skill!",
  "varietyTaoyuan3Desc": "A famous fragrant rice from northern Taiwan, emitting a subtle aroma of popcorn and taro. The grains are large and plump.",
  "varietyTaoyuan3Fact": "Knowledge: The representative variety of Taoyuan and Hsinchu. Its excellent cold tolerance makes it perfectly suited for the wet and cold autumns of the north.",
  "varietyKaohsiung147Desc": "An emerging champion fragrant rice from the south. It features a unique, elegant taro aroma, a glossy finish, and a sweet taste that wins competitions year after year.",
  "varietyKaohsiung147Fact": "Knowledge: Specifically bred for the hot climate of Kaohsiung and Pingtung, giving southern Taiwan its very own top-tier fragrant rice to be proud of.",
  "varietyTainung67Desc": "The legendary variety that once dominated Taiwan's rice fields! With immense adaptability and ultra-high yields, it's the collective memory of Taiwan's 1980s rural life.",
  "varietyTainung67Fact": "Knowledge: Though it has gradually phased out due to newer, tastier varieties, its robust vitality saved the livelihoods of countless farming families."
}

ja_desc = {
  "varietyTainan11Desc": "台湾で最も広く栽培されている品種。ふっくらとした粒と高い収量が特徴で、台湾を代表する白米です。",
  "varietyTainan11Fact": "知識カード：病害虫に強く、安定した収量を誇り、台湾農業の屋台骨として活躍しています。",
  "varietyKaohsiung139Desc": "台湾東部の主力品種。米粒の中心がやや白濁していますが、その味と食感は格別です。",
  "varietyKaohsiung139Fact": "知識カード：外見はイマイチですが味が絶品なため、農家から「醜い美人」と呼ばれています。東部の綺麗な水がその風味を育てます。",
  "varietyTainung71Desc": "台湾中部の名米。炊き上がると豊かなタロイモの香りが広がります。短く丸い粒で、もっちりとした食感です。",
  "varietyTainung71Fact": "知識カード：「益全」という名は、この品種の開発に生涯を捧げ、発表直前に過労で倒れた郭益全博士を記念して名付けられました。",
  "varietyTaikeng9Desc": "台湾北部でよく見られる高品質な品種。冷めてももっちりとした食感が残るため、高級おにぎりや寿司に最適です。",
  "varietyTaikeng9Fact": "知識カード：冷めても固くなりにくい特性から、多くの大手コンビニチェーンで高級おにぎり用に指定されています！",
  "varietyTaichungSen10Desc": "台湾で最も生産量が多く、最高に美味しいインディカ米（長粒米）。食物繊維が豊富でデンプンが少なく、ふっくらとして粘り気が少ないのが特徴です。",
  "varietyTaichungSen10Fact": "知識カード：インディカ米は美味しくないという固定観念を完全に打ち砕き、ベジタリアン料理やチャーハンの定番となりました。",
  "varietyKoshihikariDesc": "日本生まれの伝説的なスーパー品種。透き通った粒と強い粘り気、比類のない食感を持っていますが、栽培は非常に困難です。",
  "varietyKoshihikariFact": "知識カード：本来台湾の気候は暑すぎますが、池上の農家の方々の卓越した技術により栽培に成功しています！",
  "varietyTaoyuan3Desc": "台湾北部の有名な香り米。ポップコーンやタロイモのほのかな香りがします。粒が大きくふっくらとしています。",
  "varietyTaoyuan3Fact": "知識カード：桃園・新竹地域の代表的な品種。優れた耐寒性を持つため、北部の湿って冷え込む秋冬の気候に最適です。",
  "varietyKaohsiung147Desc": "南部から登場した新進気鋭のチャンピオン香り米。上品なタロイモの香りと艶があり、甘みのある味わいで毎年コンクールで優勝しています。",
  "varietyKaohsiung147Fact": "知識カード：高雄や屏東の暑い気候に合わせて開発され、台湾南部に誇るべき独自の最高級香り米をもたらしました。",
  "varietyTainung67Desc": "かつて台湾の田んぼを席巻した伝説の品種！驚異的な適応力と超多収量を誇り、1980年代の台湾農村の共通の記憶となっています。",
  "varietyTainung67Fact": "知識カード：食味の良い新品種に押されて徐々に姿を消しましたが、その強靭な生命力は無数の農家の生計を救いました。"
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

update_arb("en", en_desc)
update_arb("ja", ja_desc)

print("Descriptions translated.")
