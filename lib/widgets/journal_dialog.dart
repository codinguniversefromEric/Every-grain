import 'package:flutter/material.dart';
import '../models/field_state.dart';

class JournalDialog extends StatelessWidget {
  final bool isFirstLetter;
  final bool needsPlanting;
  final VoidCallback onStartTask;
  final FieldState? state;
  final VoidCallback? onPlowDeadCrop;
  final VoidCallback? onPrayToEarthGod;

  const JournalDialog({
    super.key,
    required this.isFirstLetter,
    required this.needsPlanting,
    required this.onStartTask,
    this.state,
    this.onPlowDeadCrop,
    this.onPrayToEarthGod,
  });

  @override
  Widget build(BuildContext context) {
    String title = "農事日誌";
    String content = "";
    String buttonText = "關閉";
    VoidCallback action = () => Navigator.of(context).pop();
    bool showPrayButton = false;

    if (isFirstLetter) {
      title = "阿公的信";
      content = "孩子，歡迎來到這片田。\n\n這裡不需要你每天辛苦登入除草，也不需要你花錢買肥料。\n你只需要偶爾看著它，聽聽風聲、聽聽蟲鳴。\n\n每一粒米都是時間的餽贈。去感受這片土地的呼吸吧。";
      buttonText = "我明白了";
    } else if (state?.growthStage == GrowthStage.dead) {
      title = "天有不測風雲";
      content = "極端的氣候讓植物枯萎了。\n\n這就是務農的無奈，大自然有它自己的脾氣。\n我們只能認命翻土，等待下個節氣到來，重新來過。";
      buttonText = "認命翻土";
      action = () {
        if (onPlowDeadCrop != null) onPlowDeadCrop!();
        Navigator.of(context).pop();
      };
    } else if (state?.growthStage == GrowthStage.fallow && state?.nextPlantingAllowedAt != null && DateTime.now().isBefore(state!.nextPlantingAllowedAt!)) {
      title = "休養生息";
      content = "田地正在休養生息。\n我們靜待下一個節氣到來，再重新播種。";
    } else if (needsPlanting) {
      title = "今日農事：插秧";
      content = "田水正好，是時候把秧苗插下去了。\n雖然辛苦，但這是一切的開始。";
      buttonText = "去田裡看看";
      action = () {
        Navigator.of(context).pop();
        onStartTask();
      };
    } else {
      content = "今天田裡沒什麼特別的事，稻子正安靜地生長著。\n\n「看天田，隨遇而安。」";
      if (state?.weatherOverrideUntil == null) {
        showPrayButton = true;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32), // space for close button
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF5D4037),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 16,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: action,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5D4037),
            side: const BorderSide(color: Color(0xFF5D4037)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 16, letterSpacing: 1),
          ),
        ),
        if (showPrayButton) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onPrayToEarthGod != null) onPrayToEarthGod!();
            },
            child: const Text(
              "氣象局報錯了，去向土地公抱怨",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }
}
