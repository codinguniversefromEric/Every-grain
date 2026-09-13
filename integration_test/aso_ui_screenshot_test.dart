// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rice_journey/main.dart' as app;
import 'package:rice_journey/widgets/journal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture ASO UI Screenshots', (WidgetTester tester) async {
    // Force traditional Chinese locale for ASO screenshots
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_locale', 'zh');
    try {
      await binding.convertFlutterSurfaceToImage();
    } catch (e) {
      print('convertFlutterSurfaceToImage not supported or failed: $e');
    }
    
    // 設為 false，讓日記與圖鑑按鈕顯示出來
    app.isTakingScreenshot = false;
    app.main();
    await tester.pump(const Duration(seconds: 3));

    final stateManager = app.globalStateManager!;
    while (stateManager.isLoading) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // -------------------------------------------------------------------------
    // 截圖：阿公的日記
    // -------------------------------------------------------------------------
    final journalFinder = find.byType(JournalButton);
    if (journalFinder.evaluate().isNotEmpty) {
      await tester.tap(journalFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await binding.takeScreenshot('screenshot_ui_journal');
      print('✅ Screenshot taken: Journal');
      
      // 點擊對話框外側關閉
      await tester.tapAt(const Offset(10, 10)); 
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // -------------------------------------------------------------------------
    // 截圖：稻米圖鑑
    // -------------------------------------------------------------------------
    final collectionFinder = find.byIcon(Icons.library_books);
    if (collectionFinder.evaluate().isNotEmpty) {
      await tester.tap(collectionFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await binding.takeScreenshot('screenshot_ui_collection');
      print('✅ Screenshot taken: Collection');
      
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    }
  });
}
