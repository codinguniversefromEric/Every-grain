import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate ASO Screenshots', (WidgetTester tester) async {
    // We can define the same storyboard
    final Map<String, Map<String, dynamic>> _storyboard = {
      'zh': {
        'fontFamily': 'Noto Serif TC',
        'screens': [
          {'bg': 'screenshot_1_seedling.png', 'main': '在手機裡，\n種一分安靜的田', 'sub': '拋下城市的喧囂，\n感受晨光與微風。', 'stamp': '休耕大吉'},
          {'bg': 'screenshot_2_stormy.png', 'main': '與真實世界的\n雲雨同步', 'sub': '中央氣象署資料連動，\n窗外下雨，田裡也下雨。', 'stamp': '風調雨順'},
          {'bg': 'screenshot_3_local_variety.png', 'main': '翻開阿公的日記', 'sub': '依據你的真實定位，\n解鎖台灣各地的專屬稻米品種。', 'stamp': '高雄139'},
          {'bg': 'screenshot_4_night_time.png', 'main': '從一粒種子\n到金黃稻穗', 'sub': '二十四節氣的漫長陪伴，\n沒有推播，只有安靜的生長。', 'stamp': '粒粒皆辛苦'},
          {'bg': 'screenshot_5_harvested_clean.png', 'main': '好好吃飯，\n好好生活', 'sub': '收割你的第一碗白飯，\n感受最純粹的陪伴。', 'stamp': '大豐收'},
        ]
      },
      'en': {
        'fontFamily': 'Georgia',
        'screens': [
          {'bg': 'screenshot_1_seedling.png', 'main': 'A quiet field\nin your pocket', 'sub': 'Leave the city noise behind.\nFeel the morning light.', 'stamp': 'ZEN'},
          {'bg': 'screenshot_2_stormy.png', 'main': 'Synced with\nyour real sky', 'sub': 'When it rains outside your window,\nit rains in the app.', 'stamp': 'STORM'},
          {'bg': 'screenshot_3_local_variety.png', 'main': 'Grandpa\'s Journal', 'sub': 'Unlock local rice varieties\nbased on your location.', 'stamp': 'K-139'},
          {'bg': 'screenshot_4_night_time.png', 'main': 'From seed\nto golden harvest', 'sub': 'No rush. Just quiet growth\nover 24 solar terms.', 'stamp': 'GROWTH'},
          {'bg': 'screenshot_5_harvested_clean.png', 'main': 'Eat well,\nlive well', 'sub': 'Harvest your first bowl of rice\nand feel the purest companionship.', 'stamp': 'HARVEST'},
        ]
      },
      'ja': {
        'fontFamily': 'Noto Serif JP',
        'screens': [
          {'bg': 'screenshot_1_seedling.png', 'main': 'スマホの中に、\n静かな田んぼを', 'sub': '都会の喧騒を離れ、\n朝の光とそよ風を感じる。', 'stamp': '豊作'},
          {'bg': 'screenshot_2_stormy.png', 'main': '現実の天気と\nつながる', 'sub': '窓の外が雨なら、\nスマホの中も雨が降る。', 'stamp': '恵みの雨'},
          {'bg': 'screenshot_3_local_variety.png', 'main': 'おじいちゃんの日記', 'sub': '現在地から、台湾各地の\n固有品種をアンロック。', 'stamp': '高雄139'},
          {'bg': 'screenshot_4_night_time.png', 'main': '一粒の種から\n黄金の稲穂へ', 'sub': '通知も急ぎもない。\n二十四節気と共に静かに育つ。', 'stamp': '一粒万倍'},
          {'bg': 'screenshot_5_harvested_clean.png', 'main': 'よく食べ、\nよく生きる', 'sub': '最初の一杯を収穫し、\n最も純粋な寄り添いを感じよう。', 'stamp': '大豊作'},
        ]
      },
    };

    // ASO 尺寸 (1242 x 2688)
    const double targetWidth = 1242;
    const double targetHeight = 2688;
    
    // Set logical size for the headless test environment
    tester.view.physicalSize = const Size(targetWidth, targetHeight);
    tester.view.devicePixelRatio = 1.0;

    for (var locale in _storyboard.keys) {
      final config = _storyboard[locale]!;
      final screens = config['screens'] as List;
      final fontFamily = config['fontFamily'] as String;

      for (int i = 0; i < screens.length; i++) {
        final screenData = screens[i];
        final GlobalKey repaintKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(
                key: repaintKey,
                child: Container(
                  width: targetWidth,
                  height: targetHeight,
                  color: const Color(0xFFF2EBE1),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF8B7355), width: 6),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 250 * 3.0,
                          height: 520 * 3.0,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(72),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 60, offset: Offset(0, 30))
                            ],
                            image: DecorationImage(
                              // Using absolute path or proper File depending on test running dir
                              image: FileImage(File('screenshots/${screenData['bg']}')),
                              fit: BoxFit.cover,
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(72),
                            border: Border.all(color: Colors.black87, width: 18),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 120,
                        left: 0,
                        right: 0,
                        child: Text(
                          screenData['main']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 84,
                            height: 1.3,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 180,
                        left: 0,
                        right: 0,
                        child: Text(
                          screenData['sub']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 42,
                            height: 1.5,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 450,
                        right: 90,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade800, width: 6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              screenData['stamp']!,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 48,
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
        );

        // Wait for images and fonts to render
        await tester.pump(const Duration(seconds: 2));

        final RenderRepaintBoundary boundary =
            repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        
        if (byteData != null) {
          final file = File('website/assets/screenshots/aso_${locale}_screen_${i + 1}.png');
          if (!await file.parent.exists()) {
            await file.parent.create(recursive: true);
          }
          await file.writeAsBytes(byteData.buffer.asUint8List());
          print('Saved: ${file.path}');
        }
      }
    }
  });
}
