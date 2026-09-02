import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // For RiceJourneyApp.setLocale

class AboutScreen extends StatelessWidget {
  final bool isInTaiwan;

  const AboutScreen({super.key, this.isInTaiwan = true});

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2214),
          title: Text(
            loc.languageName,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'English',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  RiceJourneyApp.setLocale(context, const Locale('en', ''));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  '繁體中文',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  RiceJourneyApp.setLocale(context, const Locale('zh', 'TW'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('日本語', style: TextStyle(color: Colors.white)),
                onTap: () {
                  RiceJourneyApp.setLocale(context, const Locale('ja', 'JP'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  loc.languageSystem,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  RiceJourneyApp.setLocale(context, null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1915), // Deep earthy dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: 'Language',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Title
              const Icon(Icons.spa, size: 48, color: Color(0xFFD4AF37)),
              const SizedBox(height: 16),
              Text(
                loc.aboutTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Description
              Text(
                loc.aboutSubtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Data Sources
              Text(
                loc.aboutDataSourceTitle,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.aboutDataWeatherTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.aboutDataWeatherDesc,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.aboutDataRiceTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.aboutDataRiceDesc,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Open Source
              Text(
                loc.aboutOpenSourceTitle,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.aboutOpenSourceDesc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              _buildOutlinedButton(
                context,
                text: loc.aboutGithubButton,
                icon: Icons.open_in_new,
                onTap: () async {
                  final parsedUrl = Uri.parse('https://github.com/codinguniversefromEric/Every-grain');
                  if (await canLaunchUrl(parsedUrl)) {
                    await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildOutlinedButton(
                context,
                text: loc.aboutRateButton,
                icon: Icons.star_rate_rounded,
                onTap: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  if (await inAppReview.isAvailable()) {
                    inAppReview.openStoreListing(appStoreId: '6677028169'); // Replace with actual Apple ID if available
                  }
                },
              ),

              const SizedBox(height: 64),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF9E2A2B),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '臺\n灣',
                    style: TextStyle(
                      color: Color(0xFF9E2A2B), // Traditional seal red
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  loc.aboutCraftedWith,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, {required String text, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ],
        ),
      ),
    );
  }
}
