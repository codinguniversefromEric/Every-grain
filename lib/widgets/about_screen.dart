import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  final bool isInTaiwan;

  const AboutScreen({
    super.key,
    this.isInTaiwan = true,
  });

  // ==========================================================================
  // Colors — Old Taiwanese Agricultural Book
  // ==========================================================================

  static const Color paper = Color(0xFFE8DFC8);
  static const Color paperLight = Color(0xFFF3EAD5);
  static const Color paperDark = Color(0xFFD7C9AA);

  static const Color ink = Color(0xFF3E3026);
  static const Color inkLight = Color(0xFF6B5848);

  static const Color fadedGold = Color(0xFF9A7B32);
  static const Color sealRed = Color(0xFF9E2A2B);

  // ==========================================================================
  // Language Dialog
  // ==========================================================================

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            decoration: BoxDecoration(
              color: paperLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ink.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(5, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                20,
                22,
                18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sectionRule(),

                  const SizedBox(height: 14),

                  Text(
                    loc.languageName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _languageItem(
                    context: dialogContext,
                    title: 'English',
                    locale: const Locale('en', ''),
                  ),

                  _languageItem(
                    context: dialogContext,
                    title: '繁體中文',
                    locale: const Locale('zh', 'TW'),
                  ),

                  _languageItem(
                    context: dialogContext,
                    title: '日本語',
                    locale: const Locale('ja', 'JP'),
                  ),

                  _languageItem(
                    context: dialogContext,
                    title: loc.languageSystem,
                    locale: null,
                    muted: true,
                  ),

                  const SizedBox(height: 4),

                  _sectionRule(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageItem({
    required BuildContext context,
    required String title,
    required Locale? locale,
    bool muted = false,
  }) {
    return InkWell(
      onTap: () {
        RiceJourneyApp.setLocale(context, locale);
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ink.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted
                ? ink.withValues(alpha: 0.42)
                : ink,
            fontSize: 16,
            height: 1.35,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Main
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: paper,

      appBar: AppBar(
        backgroundColor: paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: ink,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: inkLight,
              size: 22,
            ),
            onPressed: () => _showLanguageDialog(context),
            tooltip: loc.languageName,
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 620,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ======================================================
                      // Book Header
                      // ======================================================

                      _buildBookHeader(loc),

                      const SizedBox(height: 34),

                      // ======================================================
                      // Description
                      // ======================================================

                      _buildPaperSection(
                        child: Text(
                          loc.aboutSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: inkLight,
                            fontSize: 15,
                            height: 1.75,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ======================================================
                      // Data Sources
                      // ======================================================

                      _buildSectionTitle(
                        loc.aboutDataSourceTitle,
                      ),

                      const SizedBox(height: 10),

                      _buildDataSourceSection(loc),

                      const SizedBox(height: 34),

                      // ======================================================
                      // Open Source
                      // ======================================================

                      _buildSectionTitle(
                        loc.aboutOpenSourceTitle,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        loc.aboutOpenSourceDesc,
                        style: const TextStyle(
                          color: inkLight,
                          fontSize: 14,
                          height: 1.65,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildBookButton(
                        context,
                        text: loc.aboutGithubButton,
                        icon: Icons.open_in_new,
                        onTap: () async {
                          final uri = Uri.parse(
                            'https://github.com/codinguniversefromEric/Every-grain',
                          );

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildBookButton(
                        context,
                        text: loc.aboutRateButton,
                        icon: Icons.rate_review_outlined,
                        onTap: () async {
                          final review = InAppReview.instance;

                          if (await review.isAvailable()) {
                            await review.openStoreListing(
                              appStoreId: '6677028169',
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 48),

                      // ======================================================
                      // Taiwan Seal
                      // ======================================================

                      _buildTaiwanSeal(),

                      const SizedBox(height: 18),

                      Text(
                        loc.aboutCraftedWith,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ink.withValues(alpha: 0.48),
                          fontSize: 11,
                          height: 1.4,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildBottomLine(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // Header
  // ==========================================================================

  Widget _buildBookHeader(AppLocalizations loc) {
    return Column(
      children: [
        // Small publication mark
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: ink.withValues(alpha: 0.25),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '農事小誌',
                style: TextStyle(
                  color: inkLight,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),
            ),

            Expanded(
              child: Container(
                height: 1,
                color: ink.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Rice seal / illustration
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: paperDark,
            shape: BoxShape.circle,
            border: Border.all(
              color: fadedGold.withValues(alpha: 0.65),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.grass,
              size: 38,
              color: fadedGold,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          loc.aboutTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ink,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        _sectionRule(),

        const SizedBox(height: 10),

        Text(
          'EVERY GRAIN',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ink.withValues(alpha: 0.48),
            fontSize: 10,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Section Title
  // ==========================================================================

  Widget _buildSectionTitle(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 24,
          color: fadedGold,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Data Sources
  // ==========================================================================

  Widget _buildDataSourceSection(AppLocalizations loc) {
    return _buildPaperSection(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceEntry(
            title: loc.aboutDataWeatherTitle,
            description: loc.aboutDataWeatherDesc,
          ),

          const SizedBox(height: 18),

          Container(
            height: 1,
            color: ink.withValues(alpha: 0.12),
          ),

          const SizedBox(height: 18),

          _buildSourceEntry(
            title: loc.aboutDataRiceTitle,
            description: loc.aboutDataRiceDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceEntry({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          description,
          style: const TextStyle(
            color: inkLight,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Paper Section
  // ==========================================================================

  Widget _buildPaperSection({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: paperLight,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: ink.withValues(alpha: 0.16),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================================================
  // Book Button
  // ==========================================================================

  Widget _buildBookButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 54,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: paperLight.withValues(alpha: 0.72),
            border: Border.all(
              color: ink.withValues(alpha: 0.25),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: fadedGold,
                size: 20,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right,
                color: inkLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Taiwan Seal
  // ==========================================================================

  Widget _buildTaiwanSeal() {
    return Center(
      child: Container(
        width: 58,
        height: 66,
        padding: const EdgeInsets.all(4),
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
              '臺\n灣',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: sealRed,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Decoration
  // ==========================================================================

  Widget _sectionRule() {
    return Container(
      height: 1,
      color: ink.withValues(alpha: 0.25),
    );
  }

  Widget _buildBottomLine() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: ink.withValues(alpha: 0.15),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: fadedGold.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: ink.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
