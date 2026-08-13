import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showMockIAPDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2214),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          title: const Text('感謝您的心意', style: TextStyle(color: Color(0xFFD4AF37))),
          content: Text(
            '您點擊了贊助「$itemName」。\n\n目前開發者正在與銀行連線中 (Mock IAP)，敬請期待未來的更新！',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('返回田裡', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        );
      },
    );
  }

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

              // Data Sources (Requested by user)
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
                    Text('交通部中央氣象署 (CWA) 開放資料平台', style: TextStyle(color: Colors.white60, fontSize: 14)),
                    SizedBox(height: 16),
                    Text('🌾 在地稻米品種知識', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('農業部各區農業改良場 (TARI) 及台灣米食推廣資料', style: TextStyle(color: Colors.white60, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Tip Jar
              const Text(
                '支持農夫 (Tip Jar)',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '如果您享受這片寧靜的田地，歡迎隨喜贊助，讓這片田能持續運轉。',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),

              _buildDonateButton(context, '🍵 請農夫喝杯青草茶', 'US\$ 0.99'),
              const SizedBox(height: 12),
              _buildDonateButton(context, '🍱 請農夫吃個排骨便當', 'US\$ 2.99'),
              const SizedBox(height: 12),
              _buildDonateButton(context, '🌾 贊助一包有機肥料', 'US\$ 4.99'),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonateButton(BuildContext context, String title, String price) {
    return InkWell(
      onTap: () => _showMockIAPDialog(context, title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(price, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
