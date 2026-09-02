import 'package:flutter/material.dart';
import '../models/field_state.dart';

class JournalDialog extends StatelessWidget {
  final bool isFirstLetter;
  final bool needsPlanting;
  final VoidCallback onStartTask;

  const JournalDialog({
    super.key,
    required this.isFirstLetter,
    required this.needsPlanting,
    required this.onStartTask,
  });

  @override
  Widget build(BuildContext context) {
    String title = "農事日誌";
    String content = "";
    String buttonText = "關閉";
    VoidCallback action = () => Navigator.of(context).pop();

    if (isFirstLetter) {
      title = "阿公的信";
      content = "孩子，歡迎來到這片田。\n\n這裡不需要你每天辛苦登入除草，也不需要你花錢買肥料。\n你只需要偶爾看著它，聽聽風聲、聽聽蟲鳴。\n\n每一粒米都是時間的餽贈。去感受這片土地的呼吸吧。";
      buttonText = "我明白了";
    } else if (needsPlanting) {
      title = "今日農事：插秧";
      content = "春天的雨水已經潤濕了田地，是時候把秧苗插下去了。\n雖然辛苦，但這是一切的開始。";
      buttonText = "去田裡看看";
      action = () {
        Navigator.of(context).pop();
        onStartTask();
      };
    } else {
      content = "今天田裡沒什麼特別的事，稻子正安靜地生長著。\n\n「看天田，隨遇而安。」";
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EAD5), // Old paper color
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
          ],
        ),
      ),
    );
  }
}
