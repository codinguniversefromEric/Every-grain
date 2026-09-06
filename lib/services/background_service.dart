import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'state_manager.dart';
import 'widget_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint("Native called background task: $task");
      // Initialize what we need
      final stateManager = StateManager();
      await stateManager.initializeState();
      
      // We might need to initialize WidgetService if not already
      await WidgetService.init();
      
      // Update the widget with the latest state
      await WidgetService.updateWidget(
        stateManager.state, 
        hasUnreadJournal: stateManager.hasUnreadJournal
      );
      
      debugPrint("Background task completed successfully");
      return true;
    } catch (e) {
      debugPrint("Background task failed: $e");
      return false;
    }
  });
}

class BackgroundService {
  static const String taskName = "updateWidgetTask";

  static Future<void> init() async {
    if (kIsWeb) return;
    
    await Workmanager().initialize(
      callbackDispatcher,
      
    );

    // Schedule a periodic task every 15 minutes (minimum for Android)
    await Workmanager().registerPeriodicTask(
      "widget_update",
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }
}
