import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const AsoGeneratorApp());
}

class AsoGeneratorApp extends StatelessWidget {
  const AsoGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AsoGeneratorScreen(),
    );
  }
}

class AsoGeneratorScreen extends StatefulWidget {
  const AsoGeneratorScreen({super.key});

  @override
  State<AsoGeneratorScreen> createState() => _AsoGeneratorScreenState();
}

class _AsoGeneratorScreenState extends State<AsoGeneratorScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGenerating = false;
  String _status = "Ready to generate Custom ASO screenshots";

  String _currentLocale = 'zh';
  int _currentScreenIndex = 0;

  final Map<String, Map<String, dynamic>> _storyboard = {
    'zh': {
      'fontFamily': 'Microsoft JhengHei',
      'screens': [
        {'main': '寄生於桌面的\n安靜窗景', 'sub': '無需打開 App。在主畫面，\n看見今日的風土與節氣。', 'stamp': '陪伴'},
        {'main': '陰晴圓缺，\n與現實天空連動', 'sub': '晴天、雷雨、日落與星空。\n與這片土地共度每一個時刻。', 'stamp': '風調雨順'},
        {'main': '翻開日誌，\n找回失落的記憶', 'sub': '結合農民曆與節氣知識，\n閱讀阿公留下來的溫暖對話。', 'stamp': '霜降'},
        {'main': '尋訪全台，\n收集在地稻米圖鑑', 'sub': '依據你的真實定位，\n遇見專屬當地的稻種與故事。', 'stamp': '高雄139'},
        {'main': '粒粒皆辛苦，\n化作一碗白飯', 'sub': '簡單，卻是最純粹的豐收。\n今日農事已畢，去忙你的吧。', 'stamp': '大豐收'},
      ],
      'featureGraphic': '粒粒 Every-grain\n在手機裡，種一分安靜的田'
    },
    'en': {
      'fontFamily': 'Arial',
      'screens': [
        {'main': 'A quiet window\non your home screen', 'sub': 'No need to open the app.\nSee today\'s weather at a glance.', 'stamp': 'COMPANION'},
        {'main': 'Synced with\nthe real sky', 'sub': 'Sun, rain, sunset, and stars.\nShare every moment with the land.', 'stamp': 'WEATHER'},
        {'main': 'Open the diary,\nfind lost memories', 'sub': 'Discover seasonal knowledge and read\nthe warm words left by Grandpa.', 'stamp': 'JOURNAL'},
        {'main': 'Collect local\nrice varieties', 'sub': 'Based on your real location,\ndiscover unique rice types.', 'stamp': 'K-139'},
        {'main': 'Every grain a journey,\nending in a bowl', 'sub': 'Simple, yet the purest harvest.\nToday\'s work is done.', 'stamp': 'HARVEST'},
      ],
      'featureGraphic': 'Every-grain\nA quiet field in your pocket'
    },
    'ja': {
      'fontFamily': 'Arial',
      'screens': [
        {'main': 'ホーム画面に、\n静かな窓を', 'sub': 'アプリを開かなくても、\n今日の天気と季節を感じる。', 'stamp': '寄り添い'},
        {'main': '現実の空と\nリンクする', 'sub': '晴れ、雨、夕暮れ、そして星空。\nこの土地のあらゆる瞬間を共に。', 'stamp': '恵みの雨'},
        {'main': '日記を開き、\n失われた記憶を辿る', 'sub': '季節の知識に触れ、おじいちゃんが\n残した温かい言葉を読む。', 'stamp': '霜降'},
        {'main': '台湾各地の\n稲図鑑を集める', 'sub': 'あなたの現在地から、\nその土地特有の品種に出会う。', 'stamp': '高雄139'},
        {'main': '一粒の旅が、\n一杯の白飯に', 'sub': 'シンプルでありながら、純粋な実り。\n今日の農作業はここまで。', 'stamp': '大豊作'},
      ],
      'featureGraphic': '粒粒 Every-grain\nスマホの中に、静かな田んぼを'
    },
  };

  Future<void> _generateAllImages() async {
    setState(() {
      _isGenerating = true;
      _status = "Generating 15 Custom Images...";
    });

    for (var locale in _storyboard.keys) {
      for (int i = 0; i <= 5; i++) { // 0~4 are screenshots, 5 is Feature Graphic
        setState(() {
          _currentLocale = locale;
          _currentScreenIndex = i;
          _status = i == 5 
              ? "Generating [$locale] Feature Graphic..."
              : "Generating [$locale] screen ${i + 1}/5...";
        });
        
        await Future.delayed(const Duration(milliseconds: 1000));
        // Feature Graphic uses pixelRatio 2.0 (since UI is scaled by 0.5), Screenshots use 3.0
        final pixelRatio = i == 5 ? 2.0 : 3.0;
        final image = await _captureWidget(pixelRatio);
        if (image != null) {
          final filename = i == 5 
              ? 'feature_graphic_$locale.png' 
              : 'aso_${locale}_screen_${i + 1}.png';
          await _saveImage(image, filename);
        }
      }
    }

    setState(() {
      _isGenerating = false;
      _status = "All Images & Feature Graphics Done! Check website/assets/screenshots/";
    });
  }

  Future<ui.Image?> _captureWidget(double pixelRatio) async {
    try {
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _saveImage(ui.Image image, String filename) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final file = File('website/assets/screenshots/$filename');
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }

  Widget _buildMockPhoneContent(int screenIndex, String fontFamily) {
    // 依據不同的螢幕索引，渲染不同的假 UI 與斜切效果
    switch (screenIndex) {
      case 0: // Widget
        return Stack(
          children: [
            Image.file(File('screenshots/screenshot_1_seedling.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            // Mock home screen blur
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            // App Icons Grid
            Positioned(
              top: 50, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)))),
              ),
            ),
            // Rice Journey Widget Mock (Just a simple image widget as in the real app)
            Positioned(
              top: 130, left: 20, right: 20,
              child: Container(
                height: 240, // Square-ish proportion for the widget
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8))],
                  image: DecorationImage(
                    image: FileImage(File('screenshots/screenshot_1_seedling.png')), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        );
      case 1: // Weather Split
        return Stack(
          children: [
            // Bottom layer (Night)
            Image.file(File('screenshots/screenshot_4_night_time.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            // Middle layer (Stormy)
            ClipPath(
              clipper: _DiagonalClipper(0.65),
              child: Image.file(File('screenshots/screenshot_2_stormy.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            // Top layer (Sunny)
            ClipPath(
              clipper: _DiagonalClipper(0.35),
              child: Image.file(File('screenshots/screenshot_1_seedling.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            // Split Lines
            CustomPaint(
              painter: _DiagonalLinePainter(0.65),
              child: Container(),
            ),
            CustomPaint(
              painter: _DiagonalLinePainter(0.35),
              child: Container(),
            ),
          ],
        );
      case 2: // Diary
        return Stack(
          children: [
            Image.file(File('screenshots/screenshot_3_local_variety.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            Center(
              child: Container(
                width: 240, height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EAD5), // Match book_modal paperBackground
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(10, 10))
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "阿公的日誌",
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: const Color(0xFF5D4037),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "霜降。今日有雨。\n田裡的水位要注意，\n秧苗似乎長高了一寸...\n\n- 高雄139號",
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: const Color(0xFF3E2723),
                        fontSize: 14,
                        height: 1.8,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5D4037),
                        side: const BorderSide(color: Color(0xFF5D4037)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("闔上", style: TextStyle(fontFamily: fontFamily, fontSize: 16, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 3: // Guide Cards
        return Stack(
          children: [
            Image.file(File('screenshots/screenshot_4_night_time.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            // Floating cards
            Positioned(
              top: 100, left: 20,
              child: Transform.rotate(
                angle: -0.15,
                child: _buildRiceCard("台南11號", "📍 嘉南平原", fontFamily, 'screenshot_1_seedling.png'),
              ),
            ),
            Positioned(
              top: 180, right: 10,
              child: Transform.rotate(
                angle: 0.1,
                child: _buildRiceCard("高雄139號", "📍 花東縱谷", fontFamily, 'screenshot_3_local_variety.png'),
              ),
            ),
            Positioned(
              top: 300, left: 30,
              child: Transform.rotate(
                angle: -0.05,
                child: _buildRiceCard("台稉9號", "📍 彰化西螺", fontFamily, 'screenshot_2_stormy.png'),
              ),
            ),
          ],
        );
      case 4: // Harvest
        return Stack(
          children: [
            Image.file(File('screenshots/screenshot_5_harvested_clean.png'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Center(
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EAD5).withOpacity(0.95), // Match journal paper
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white30, blurRadius: 40, spreadRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🍚", style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 10),
                    Text("豐收", style: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildRiceCard(String title, String location, String fontFamily, String bg) {
    return Container(
      width: 140, height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EAD5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(2, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              // Align to bottom center to show the actual rice plant instead of empty sky
              child: Image.file(File('screenshots/$bg'), fit: BoxFit.cover, width: double.infinity, alignment: Alignment.bottomCenter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
                const SizedBox(height: 4),
                Text(location, style: TextStyle(fontFamily: fontFamily, fontSize: 11, color: Colors.red.shade800, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _storyboard[_currentLocale]!;
    final fontFamily = config['fontFamily'] as String;
    
    // 如果是 5，代表要產生 1024x500 的 Google Play 主題圖片 (Feature Graphic)
    if (_currentScreenIndex == 5) {
      final featureText = config['featureGraphic'] as String;
      // 在桌面預覽時等比例縮小 (1024/2 = 512, 500/2 = 250)，但導出時 pixelRatio 會放大回去
      const double fgWidth = 1024 / 2;
      const double fgHeight = 500 / 2;
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rice Journey Ultimate ASO Generator'),
          actions: [
            if (!_isGenerating)
              IconButton(icon: const Icon(Icons.play_arrow), onPressed: _generateAllImages),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      width: fgWidth,
                      height: fgHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: FileImage(File('screenshots/screenshot_3_local_variety.png')),
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.all(40),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          featureText,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 28, // Scaled for the /2 preview box
                            height: 1.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 原本的 5 張 ASO 截圖排版
    final screenData = config['screens'][_currentScreenIndex];
    // Google Play requires strictly 9:16 ratio (1080 x 1920)
    const double targetWidth = 1080 / 3; // 360
    const double targetHeight = 1920 / 3; // 640

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rice Journey Ultimate ASO Generator'),
        actions: [
          if (!_isGenerating)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _generateAllImages,
            ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    width: targetWidth,
                    height: targetHeight,
                    color: const Color(0xFFF2EBE1),
                    child: Stack(
                      children: [
                        // Background Frame
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF8B7355), width: 2),
                            ),
                          ),
                        ),
                        
                        // Phone Mockup
                        Positioned(
                          top: 130,
                          left: 20, 
                          child: Container(
                            width: 260,
                            height: 480,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(8, 12))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildMockPhoneContent(_currentScreenIndex, fontFamily),
                            ),
                          ),
                        ),
                        
                        // Phone Bezel
                        Positioned(
                          top: 130, left: 20,
                          child: Container(
                            width: 260, height: 480,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black87, width: 5),
                            ),
                          ),
                        ),
                        
                        // Top Main Text
                        Positioned(
                          top: 35, left: 0, right: 0,
                          child: Text(
                            screenData['main']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 26,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                        
                        // Bottom Sub Text
                        Positioned(
                          bottom: 25, left: 0, right: 0,
                          child: Text(
                            screenData['sub']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              height: 1.4,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ),
                        
                        // Stamp overlapping the bottom right edge of the phone
                        Positioned(
                          top: 550,
                          left: 230,
                          child: Transform.rotate(
                            angle: -0.15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2EBE1).withOpacity(0.9), 
                                border: Border.all(color: Colors.red.shade800, width: 3),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: Text(
                                screenData['stamp']!,
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  final double splitRatio;
  _DiagonalClipper(this.splitRatio);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * splitRatio - 100);
    path.lineTo(size.width, size.height * splitRatio + 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _DiagonalLinePainter extends CustomPainter {
  final double splitRatio;
  _DiagonalLinePainter(this.splitRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(0, size.height * splitRatio - 100);
    path.lineTo(size.width, size.height * splitRatio + 100);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
