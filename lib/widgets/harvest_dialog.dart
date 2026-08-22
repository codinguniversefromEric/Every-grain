import 'package:flutter/material.dart';
import '../models/rice_variety.dart';
import '../l10n/app_localizations.dart';

class HarvestDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final RiceVariety? variety;

  const HarvestDialog({super.key, required this.onRestart, this.variety});

  String _getVarietyName(BuildContext context, RiceVariety v) {
    final loc = AppLocalizations.of(context)!;
    switch (v.id) {
      case 'tainan_11':
        return loc.varietyTainan11Name;
      case 'kaohsiung_139':
        return loc.varietyKaohsiung139Name;
      case 'tainung_71':
        return loc.varietyTainung71Name;
      case 'taikeng_9':
        return loc.varietyTaikeng9Name;
      default:
        return v.name;
    }
  }

  String _getVarietyDesc(BuildContext context, RiceVariety v) {
    final loc = AppLocalizations.of(context)!;
    switch (v.id) {
      case 'tainan_11':
        return loc.varietyTainan11Desc;
      case 'kaohsiung_139':
        return loc.varietyKaohsiung139Desc;
      case 'tainung_71':
        return loc.varietyTainung71Desc;
      case 'taikeng_9':
        return loc.varietyTaikeng9Desc;
      default:
        return v.description;
    }
  }

  String _getVarietyFact(BuildContext context, RiceVariety v) {
    final loc = AppLocalizations.of(context)!;
    switch (v.id) {
      case 'tainan_11':
        return loc.varietyTainan11Fact;
      case 'kaohsiung_139':
        return loc.varietyKaohsiung139Fact;
      case 'tainung_71':
        return loc.varietyTainung71Fact;
      case 'taikeng_9':
        return loc.varietyTaikeng9Fact;
      default:
        return v.funFact;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2214), // Dark earthy brown
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ), // Golden border
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rice_bowl, size: 60, color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                Text(
                  loc.harvestDialogMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (variety != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: Color(0xFFD4AF37),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${loc.varietyKnowledgeCardPrefix}${_getVarietyName(context, variety!)}',
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getVarietyDesc(context, variety!),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getVarietyFact(context, variety!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRestart();
                  },
                  child: Text(
                    loc.harvestDialogReplant,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
