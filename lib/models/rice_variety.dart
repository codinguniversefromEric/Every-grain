import 'package:flutter/material.dart';

/// Visual traits that differentiate each rice variety on screen.
class VarietyVisualTraits {
  final Color stemColor; // Base stem color
  final Color ripeGrainColor; // Color when ripening
  final double grainSize; // Relative size multiplier (1.0 = normal)
  final double
  grainRoundness; // width/height ratio of grain ovals (higher = rounder)
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

class RiceVariety {
  final String id;
  final String name;
  final String description;
  final String funFact;
  final VarietyVisualTraits visualTraits;

  const RiceVariety({
    required this.id,
    required this.name,
    required this.description,
    required this.funFact,
    required this.visualTraits,
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
  );
}
