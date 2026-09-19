import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/rice_variety.dart';
import '../utils/variety_l10n_extension.dart';

class HarvestDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final RiceVariety? variety;

  const HarvestDialog({
    super.key,
    required this.onRestart,
    this.variety,
  });

  // ==========================================================================
  // Old Book Palette
  // ==========================================================================

  static const Color paper = Color(0xFFE8DFC8);
  static const Color paperLight = Color(0xFFF3EAD5);
  static const Color paperDark = Color(0xFFD5C5A5);

  static const Color ink = Color(0xFF3E3026);
  static const Color inkLight = Color(0xFF6B5848);

  static const Color gold = Color(0xFF9A7B32);
  static const Color sealRed = Color(0xFF9E2A2B);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 520,
            maxHeight: 760,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ink.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(5, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                24,
                22,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==========================================================
                  // Header
                  // ==========================================================

                  _buildHeader(loc),

                  const SizedBox(height: 24),

                  // ==========================================================
                  // Message
                  // ==========================================================

                  Text(
                    loc.harvestDialogMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: inkLight,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),

                  // ==========================================================
                  // Variety Information
                  // ==========================================================

                  if (variety != null) ...[
                    const SizedBox(height: 24),
                    _buildVarietyCard(
                      context,
                      loc,
                      variety!,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ==========================================================
                  // Restart Button
                  // ==========================================================

                  _buildRestartButton(
                    context,
                    loc,
                  ),

                  const SizedBox(height: 20),

                  _buildBottomMark(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Header
  // ==========================================================================

  Widget _buildHeader(AppLocalizations loc) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: ink.withValues(alpha: 0.22),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '農事記錄',
                style: TextStyle(
                  color: inkLight,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
            ),

            Expanded(
              child: Container(
                height: 1,
                color: ink.withValues(alpha: 0.22),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ================================================================
        // Harvest Seal
        // ================================================================

        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: sealRed,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: sealRed.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                '收\n成',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sealRed,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          loc.harvestDialogMessage,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ink.withValues(alpha: 0.55),
            fontSize: 11,
            letterSpacing: 1.8,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          height: 1,
          color: ink.withValues(alpha: 0.22),
        ),
      ],
    );
  }

  // ==========================================================================
  // Variety Card
  // ==========================================================================

  Widget _buildVarietyCard(
    BuildContext context,
    AppLocalizations loc,
    RiceVariety riceVariety,
  ) {
    final name = riceVariety.localizedName(loc);
    final description = riceVariety.localizedDesc(loc);
    final fact = riceVariety.localizedFact(loc);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        18,
      ),
      decoration: BoxDecoration(
        color: paperLight,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: ink.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 4,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================================================================
          // Variety Heading
          // ================================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: paperDark,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.55),
                  ),
                ),
                child: const Icon(
                  Icons.grass,
                  color: gold,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  '${loc.varietyKnowledgeCardPrefix}$name',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            height: 1,
            color: ink.withValues(alpha: 0.12),
          ),

          const SizedBox(height: 14),

          // ================================================================
          // Description
          // ================================================================

          Text(
            description,
            style: const TextStyle(
              color: inkLight,
              fontSize: 14,
              height: 1.65,
            ),
          ),

          const SizedBox(height: 14),

          // ================================================================
          // Historical / Scientific Fact
          // ================================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              10,
            ),
            decoration: BoxDecoration(
              color: paperDark.withValues(alpha: 0.35),
              border: Border(
                left: BorderSide(
                  color: gold.withValues(alpha: 0.75),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              fact,
              style: const TextStyle(
                color: inkLight,
                fontSize: 13,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Restart Button
  // ==========================================================================

  Widget _buildRestartButton(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onRestart();
        },
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 52,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: gold.withValues(alpha: 0.75),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.replay,
                color: Color(0xFFE4D4AD),
                size: 19,
              ),

              const SizedBox(width: 10),

              Flexible(
                child: Text(
                  loc.harvestDialogReplant,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xFFE4D4AD),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Bottom Mark
  // ==========================================================================

  Widget _buildBottomMark() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: ink.withValues(alpha: 0.13),
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Container(
            height: 1,
            color: ink.withValues(alpha: 0.13),
          ),
        ),
      ],
    );
  }
}