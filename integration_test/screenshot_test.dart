import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rice_journey/main.dart' as app;
import 'package:rice_journey/services/state_manager.dart';
import 'package:rice_journey/models/field_state.dart';
import 'package:rice_journey/models/rice_variety.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture 5 App Store Screenshots', (WidgetTester tester) async {
    // Build the app
    app.isTakingScreenshot = true;
    app.main();
    // Use pump instead of pumpAndSettle because we have continuous animations (clouds, ripples)
    await tester.pump(const Duration(seconds: 3));

    // Get StateManager instance
    final stateManager = app.globalStateManager!;

    // Wait for initial state to load
    while (stateManager.isLoading) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // -------------------------------------------------------------------------
    // 截圖一：核心理念（首圖）
    // 白天、晴天、秧苗期 (Seedling)
    // -------------------------------------------------------------------------
    stateManager.updateGrowthStage(GrowthStage.seedling);
    stateManager.updateDayPhase(DayPhase.morning);
    stateManager.updateWeather(WeatherCondition.clear);
    
    // Pump animation frames (let ripples/clouds start)
    await tester.pump(const Duration(seconds: 2));
    
    // Take screenshot
    await binding.takeScreenshot('screenshot_1_seedling');
    print('✅ Screenshot 1 taken: seedling');

    // -------------------------------------------------------------------------
    // 截圖二：真實連動
    // 傍晚、雷雨 (Stormy)、抽穗期 (Heading)
    // -------------------------------------------------------------------------
    stateManager.updateGrowthStage(GrowthStage.heading);
    stateManager.updateDayPhase(DayPhase.evening);
    stateManager.updateWeather(WeatherCondition.stormy);
    
    await tester.pump(const Duration(seconds: 2));
    
    await binding.takeScreenshot('screenshot_2_stormy');
    print('✅ Screenshot 2 taken: stormy heading');

    // -------------------------------------------------------------------------
    // 截圖三：在地文化
    // 白天、晴天、成熟期 (Ripening)，高雄 139 號
    // -------------------------------------------------------------------------
    // Use teleport to trigger variety change
    await stateManager.teleportTo(23.0, 121.0); // South/East (Kaohsiung 139)
    await tester.pump(const Duration(seconds: 1));
    
    stateManager.updateGrowthStage(GrowthStage.ripening);
    stateManager.updateDayPhase(DayPhase.afternoon);
    stateManager.updateWeather(WeatherCondition.clear);
    
    await tester.pump(const Duration(seconds: 2));
    
    await binding.takeScreenshot('screenshot_3_local_variety');
    print('✅ Screenshot 3 taken: kaohsiung 139 ripening');

    // -------------------------------------------------------------------------
    // 截圖四：時間流逝
    // 夜晚、晴天、分蘖期 (Tillering)，螢火蟲與流星
    // -------------------------------------------------------------------------
    stateManager.updateGrowthStage(GrowthStage.tillering);
    stateManager.updateDayPhase(DayPhase.night);
    stateManager.updateWeather(WeatherCondition.clear);
    
    await tester.pump(const Duration(seconds: 2));
    
    await binding.takeScreenshot('screenshot_4_night_time');
    print('✅ Screenshot 4 taken: night tillering');

    // -------------------------------------------------------------------------
    // 截圖五：收穫與感謝
    // 觸發收割動畫，彈出知識卡
    // -------------------------------------------------------------------------
    stateManager.updateGrowthStage(GrowthStage.ripening);
    stateManager.updateDayPhase(DayPhase.afternoon);
    
    // Trigger harvest
    stateManager.executeHarvest(() {
      // Callback after harvest
    });
    
    // Wait for the harvest animation (2 seconds)
    await tester.pump(const Duration(seconds: 2));
    // Pump one more time to let the dialog render
    await tester.pump(const Duration(milliseconds: 500));
    
    await binding.takeScreenshot('screenshot_5_harvest_card');
    print('✅ Screenshot 5 taken: harvest card');
  });
}
