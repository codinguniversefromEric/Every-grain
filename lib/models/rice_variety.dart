class RiceVariety {
  final String id;
  final String name;
  final String description;
  final String funFact;

  const RiceVariety({
    required this.id,
    required this.name,
    required this.description,
    required this.funFact,
  });

  // Taiwan's 4 representative regional varieties
  static const RiceVariety tainan11 = RiceVariety(
    id: 'tainan_11',
    name: '台南 11 號',
    description: '全台產量最大、適應性最強的「全民天菜」。米粒飽滿、產量高，是台灣最常見的白米品種。',
    funFact: '知識卡：台南11號的抗病蟲害能力極強，不僅在台灣南部廣泛種植，甚至還曾外銷到日本，是真正的「台灣之光」！',
  );

  static const RiceVariety kaohsiung139 = RiceVariety(
    id: 'kaohsiung_139',
    name: '高雄 139 號 (醜美人)',
    description: '花東地區的主力品種。雖然米粒心腹白較多，外觀不如其他品種晶瑩剔透，但吃起來口感極佳。',
    funFact: '知識卡：外表不美麗卻極度美味，因此被農民暱稱為「醜美人」。多虧了東部的好水與較長的生長期，造就了它的絕佳風味。',
  );

  static const RiceVariety tainung71 = RiceVariety(
    id: 'tainung_71',
    name: '台農 71 號 (益全香米)',
    description: '台灣中部名米，烹煮時會散發出濃郁的芋頭香氣。米粒短圓飽滿，口感黏彈。',
    funFact: '知識卡：「益全」二字是為了紀念畢生奉獻於此品種研發，卻在品種發表前夕因過勞辭世的郭益全博士。',
  );

  static const RiceVariety taikeng9 = RiceVariety(
    id: 'taikeng_9',
    name: '台稉 9 號',
    description: '北部常見的優質品種，即使放冷了依然Q彈好吃，是製作頂級御飯糰與壽司的首選。',
    funFact: '知識卡：因為其冷卻後不易變硬的特性，許多知名連鎖超商的飯糰都是指定使用台稉9號喔！',
  );
}
