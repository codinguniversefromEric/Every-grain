import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    String title = loc.journalTitle;
    String content = "";
    String buttonText = loc.journalCloseButton;
    VoidCallback action = () => Navigator.of(context).pop();
    bool showPrayButton = false;

    if (isFirstLetter) {
      title = loc.journalGrandpaTitle;
      content = loc.journalGrandpaContent;
      buttonText = loc.journalGrandpaButton;
    } else if (state?.growthStage == GrowthStage.dead) {
      title = loc.journalDeadTitle;
      content = loc.journalDeadContent;
      buttonText = loc.journalDeadButton;
      action = () {
        if (onPlowDeadCrop != null) onPlowDeadCrop!();
        Navigator.of(context).pop();
      };
    } else if (state?.growthStage == GrowthStage.fallow && state?.nextPlantingAllowedAt != null && DateTime.now().isBefore(state!.nextPlantingAllowedAt!)) {
      title = loc.journalFallowTitle;
      content = loc.journalFallowContent;
    } else if (needsPlanting) {
      title = loc.journalPlantingTitle;
      content = loc.journalPlantingContent;
      buttonText = loc.journalPlantingButton;
      action = () {
        Navigator.of(context).pop();
        onStartTask();
      };
    } else {
      content = loc.journalNothingContent;
      if (state?.weatherOverrideUntil == null) {
        showPrayButton = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
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
            child: Text(
              loc.journalPrayButton,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ],
    ),
    );
  }
}
