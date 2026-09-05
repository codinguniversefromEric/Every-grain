import 'package:flutter/material.dart';

/// Visual traits that differentiate each rice variety on screen.
class VarietyVisualTraits {
  final Color stemColor; // Base stem color
  final Color ripeGrainColor; // Color when ripening
  final double grainSize; // Relative size multiplier (1.0 = normal)
  final double grainRoundness; // width/height ratio of grain ovals (higher = rounder)
  final double maxStalksMultiplier; // How dense the field is
  final double stalkHeightRange; // Height variation factor

  const VarietyVisualTraits({
    required this.stemColor,
    required this.ripeGrainColor,
    required this.grainSize,
    required this.grainRoundness,
    required this.maxStalksMultiplier,
    required this.stalkHeightRange,
  });
}

/// Biological traits that determine how the variety responds to the environment.
class VarietyGeneticTraits {
  final double minOptimalTemp;
  final double maxOptimalTemp;
  final double maxFloodTolerance; // mm/h before gaining water stress
  final double droughtResistance; // hours it can survive low humidity

  const VarietyGeneticTraits({
    required this.minOptimalTemp,
    required this.maxOptimalTemp,
    required this.maxFloodTolerance,
    required this.droughtResistance,
  });
}

/// Hardcore agricultural data sourced from TARI (Taiwan Agricultural Research Institute)
class VarietyTariData {
  final String crossParents; // 交配親本
  final int growthDays; // 生育日數 (大約)
  final double thousandGrainWeight; // 千粒重(克)
  final String blastResistance; // 葉稻熱病抗性
  final String brownPlanthopperResistance; // 褐飛蝨抗性
  final String grainType; // 穀粒型態 (稉米、秈米、糯米)

  const VarietyTariData({
    required this.crossParents,
    required this.growthDays,
    required this.thousandGrainWeight,
    required this.blastResistance,
    required this.brownPlanthopperResistance,
    required this.grainType,
  });
}

class RiceVariety {
  final String id;
  final String name;
  final String description;
  final String funFact;
  final VarietyVisualTraits visualTraits;
  final VarietyGeneticTraits geneticTraits;
  final VarietyTariData tariData;

  const RiceVariety({
    required this.id,
    required this.name,
    required this.description,
    required this.funFact,
    required this.visualTraits,
    required this.geneticTraits,
    required this.tariData,
  });

  static const RiceVariety tainan11 = RiceVariety(
    id: 'tainan_11',
    name: '台南 11 號',
    description: '全台產量最大、適應性最強的「全民天菜」。米粒飽滿、產量高，是台灣最常見的白米品種。',
    funFact: '知識卡：台南11號的抗病蟲害能力極強，不僅在台灣南部廣泛種植，甚至還曾外銷到日本，是真正的「台灣之光」！',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF558B2F),
      ripeGrainColor: Color(0xFFDAA520),
      grainSize: 1.1,
      grainRoundness: 1.6,
      maxStalksMultiplier: 1.2,
      stalkHeightRange: 0.45,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 22.0,
      maxOptimalTemp: 32.0,
      maxFloodTolerance: 40.0,
      droughtResistance: 72.0,
    ),
    tariData: VarietyTariData(
      crossParents: '嘉農育811221 / 台稉7號',
      growthDays: 131,
      thousandGrainWeight: 26.8,
      blastResistance: '中抗',
      brownPlanthopperResistance: '中感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety taikeng9 = RiceVariety(
    id: 'taikeng_9',
    name: '台稉 9 號',
    description: '北部常見的優質品種，即使放冷了依然Q彈好吃，是製作頂級御飯糰與壽司的首選。',
    funFact: '知識卡：因為其冷卻後不易變硬的特性，許多知名連鎖超商的飯糰都是指定使用台稉9號喔！',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF3D7A2E),
      ripeGrainColor: Color(0xFFD4AF37),
      grainSize: 1.05,
      grainRoundness: 1.4,
      maxStalksMultiplier: 1.0,
      stalkHeightRange: 0.5,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 18.0,
      maxOptimalTemp: 30.0,
      maxFloodTolerance: 45.0,
      droughtResistance: 48.0,
    ),
    tariData: VarietyTariData(
      crossParents: '北育29號 / 台農67號',
      growthDays: 135,
      thousandGrainWeight: 24.1,
      blastResistance: '中抗',
      brownPlanthopperResistance: '中感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety tainung71 = RiceVariety(
    id: 'tainung_71',
    name: '台農 71 號 (益全香米)',
    description: '台灣中部名米，烹煮時會散發出濃郁的芋頭香氣。米粒短圓飽滿，口感黏彈。',
    funFact: '知識卡：「益全」二字是為了紀念畢生奉獻於此品種研發，卻在品種發表前夕因過勞辭世的郭益全博士。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF6A8F3F),
      ripeGrainColor: Color(0xFFE8C547),
      grainSize: 0.85,
      grainRoundness: 1.8,
      maxStalksMultiplier: 1.1,
      stalkHeightRange: 0.4,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 24.0,
      maxOptimalTemp: 34.0,
      maxFloodTolerance: 35.0,
      droughtResistance: 60.0,
    ),
    tariData: VarietyTariData(
      crossParents: '絹光 / 台稉4號',
      growthDays: 125,
      thousandGrainWeight: 23.5,
      blastResistance: '中感',
      brownPlanthopperResistance: '感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety kaohsiung139 = RiceVariety(
    id: 'kaohsiung_139',
    name: '高雄 139 號 (醜美人)',
    description: '花東地區的主力品種。雖然米粒心腹白較多，外觀不如其他品種晶瑩剔透，但吃起來口感極佳。',
    funFact: '知識卡：外表不美麗卻極度美味，因此被農民暱稱為「醜美人」。多虧了東部的好水與較長的生長期，造就了它的絕佳風味。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF4E7A27),
      ripeGrainColor: Color(0xFFC8B560),
      grainSize: 1.0,
      grainRoundness: 1.5,
      maxStalksMultiplier: 1.0,
      stalkHeightRange: 0.55,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 20.0,
      maxOptimalTemp: 28.0,
      maxFloodTolerance: 30.0,
      droughtResistance: 48.0,
    ),
    tariData: VarietyTariData(
      crossParents: '屏東9號 / 臺中65號',
      growthDays: 140, // East coast takes longer
      thousandGrainWeight: 26.5,
      blastResistance: '極感', // Vulnerable
      brownPlanthopperResistance: '感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety taoyuan3 = RiceVariety(
    id: 'taoyuan_3',
    name: '桃園 3 號 (新香米)',
    description: '北部著名的香米品種，散發淡淡的爆米花香與芋香。穀粒大且飽滿。',
    funFact: '知識卡：為桃竹地區的代表性品種，由於其耐寒性極佳，非常適應北部秋冬的濕冷氣候。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF385E22),
      ripeGrainColor: Color(0xFFDEB887),
      grainSize: 1.15,
      grainRoundness: 1.45,
      maxStalksMultiplier: 1.0,
      stalkHeightRange: 0.48,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 16.0, // High cold tolerance
      maxOptimalTemp: 28.0,
      maxFloodTolerance: 50.0,
      droughtResistance: 40.0,
    ),
    tariData: VarietyTariData(
      crossParents: '台稉4號 / 台稉2號',
      growthDays: 138,
      thousandGrainWeight: 27.2,
      blastResistance: '感',
      brownPlanthopperResistance: '極感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety taichungSen10 = RiceVariety(
    id: 'taichung_sen_10',
    name: '台中秈 10 號',
    description: '台灣產量最大、也是最好吃的「秈米」(長米)。高纖低澱粉，口感鬆軟不黏。',
    funFact: '知識卡：打破了長米「乾硬」的刻板印象，是米粉與蘿蔔糕的頂級原料，深受中部農民喜愛。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF7CB342),
      ripeGrainColor: Color(0xFFE6C229),
      grainSize: 1.2,
      grainRoundness: 3.0, // Very long grain
      maxStalksMultiplier: 1.3, // High yield
      stalkHeightRange: 0.6,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 25.0,
      maxOptimalTemp: 35.0, // Loves heat
      maxFloodTolerance: 20.0,
      droughtResistance: 80.0,
    ),
    tariData: VarietyTariData(
      crossParents: 'IR 24 / Chianung-Sen 8',
      growthDays: 128,
      thousandGrainWeight: 25.5,
      blastResistance: '抗', // Strong resistance
      brownPlanthopperResistance: '感',
      grainType: '秈米',
    ),
  );

  static const RiceVariety kaohsiung147 = RiceVariety(
    id: 'kaohsiung_147',
    name: '高雄 147 號 (香鑽)',
    description: '南部新興的冠軍香米。擁有獨特的淡雅芋香與光澤，入口甘甜，連年在比賽中奪冠。',
    funFact: '知識卡：專為高屏地區炎熱氣候培育，它的出現讓南台灣有了屬於自己驕傲的頂級香米。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF689F38),
      ripeGrainColor: Color(0xFFF0E68C),
      grainSize: 1.1,
      grainRoundness: 1.5,
      maxStalksMultiplier: 1.1,
      stalkHeightRange: 0.42,
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 23.0,
      maxOptimalTemp: 33.0,
      maxFloodTolerance: 35.0,
      droughtResistance: 65.0,
    ),
    tariData: VarietyTariData(
      crossParents: '高雄145號 / 台農74號',
      growthDays: 120,
      thousandGrainWeight: 26.0,
      blastResistance: '中感',
      brownPlanthopperResistance: '中感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety koshihikari = RiceVariety(
    id: 'koshihikari',
    name: '越光米 (Koshihikari)',
    description: '來自日本的超級名種。米粒晶瑩剔透，黏性強，口感無與倫比，但極難照顧。',
    funFact: '知識卡：原本只適合高緯度氣候，後來引進台灣後，發現在氣候涼爽、水質純淨的蘭陽平原也能種出頂級的越光米！',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF2E7D32),
      ripeGrainColor: Color(0xFFFFFACD), // Very light yellow/white
      grainSize: 0.95,
      grainRoundness: 1.6,
      maxStalksMultiplier: 0.8, // Low yield
      stalkHeightRange: 0.65, // Easily lodges (falls over)
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 15.0,
      maxOptimalTemp: 26.0, // Hates heat
      maxFloodTolerance: 15.0, // Hates typhoons
      droughtResistance: 30.0,
    ),
    tariData: VarietyTariData(
      crossParents: '農林22號 / 農林1號',
      growthDays: 105, // Very fast
      thousandGrainWeight: 22.0,
      blastResistance: '極感', // Super vulnerable
      brownPlanthopperResistance: '極感',
      grainType: '稉米',
    ),
  );

  static const RiceVariety tainung67 = RiceVariety(
    id: 'tainung_67',
    name: '台農 67 號',
    description: '曾經統治台灣稻田的傳奇品種！適應力極強、產量極高，是 1980 年代台灣農村的共同記憶。',
    funFact: '知識卡：雖然現在已經因為食味品質不如新品種而逐漸被淘汰，但它強悍的生命力曾拯救了無數農家的生計。',
    visualTraits: VarietyVisualTraits(
      stemColor: Color(0xFF556B2F),
      ripeGrainColor: Color(0xFFCD853F),
      grainSize: 1.0,
      grainRoundness: 1.5,
      maxStalksMultiplier: 1.5, // Extreme yield
      stalkHeightRange: 0.3, // Very uniform
    ),
    geneticTraits: VarietyGeneticTraits(
      minOptimalTemp: 15.0,
      maxOptimalTemp: 38.0, // Indestructible
      maxFloodTolerance: 80.0,
      droughtResistance: 90.0,
    ),
    tariData: VarietyTariData(
      crossParents: '嘉農242號 / 台南5號',
      growthDays: 130,
      thousandGrainWeight: 26.0,
      blastResistance: '抗',
      brownPlanthopperResistance: '中感',
      grainType: '稉米',
    ),
  );

  static const List<RiceVariety> allVarieties = [
    tainan11,
    taikeng9,
    tainung71,
    kaohsiung139,
    taoyuan3,
    taichungSen10,
    kaohsiung147,
    koshihikari,
    tainung67,
  ];
}
