import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();
  
  Future<int> get batteryLevel async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      return 100;
    }
  }

  Stream<BatteryState> get onBatteryStateChanged => _battery.onBatteryStateChanged;
}
