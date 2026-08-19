import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1915), // Deep earthy dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54),
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
              const Text(
                '粒粒皆辛苦\nRice Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Description
              const Text(
                '這不是教人種田的遊戲，\n而是一個重新感受時間、食物與土地的陪伴。',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Data Sources
              const Text(
                '資料來源與鳴謝',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⛅️ 即時氣象連動資料', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('台灣交通部中央氣象署 (CWA)\nGlobal weather data by Open-Meteo.com', style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5)),
                    SizedBox(height: 16),
                    Text('🌾 在地稻米品種知識', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('農業部各區農業改良場 (TARI) 及台灣米食推廣資料', style: TextStyle(color: Colors.white60, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Open Source
              const Text(
                '開源與程式碼',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '本專案為完全免費之開源軟體，您可以隨時檢視、學習或貢獻程式碼。',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),

              _buildGithubButton(context),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGithubButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse('https://github.com/codinguniversefromEric/Every-grain');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('💻 前往 GitHub 檢視專案', style: TextStyle(color: Colors.white, fontSize: 16)),
            Icon(Icons.open_in_new, color: Color(0xFFD4AF37), size: 20),
          ],
        ),
      ),
    );
  }
}
