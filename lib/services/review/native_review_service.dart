import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import '../app_logger.dart';
import 'review_service.dart';

class NativeReviewService implements ReviewService {
  static const String _harvestCountKey = 'app_review_harvest_count';
  static const int _targetHarvestCount = 3;

  @override
  Future<void> checkAndRequestReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentCount = prefs.getInt(_harvestCountKey) ?? 0;
      currentCount++;

      AppLogger.i('AppReviewService: Harvest count is now $currentCount');
      await prefs.setInt(_harvestCountKey, currentCount);

      if (currentCount == _targetHarvestCount) {
        AppLogger.i('AppReviewService: Target reached. Checking InAppReview availability.');
        if (await InAppReview.instance.isAvailable()) {
          // Add a small delay so it doesn't overlap instantly with the harvest animation
          await Future.delayed(const Duration(seconds: 1));
          AppLogger.i('AppReviewService: Requesting native app review.');
          await InAppReview.instance.requestReview();
        } else {
          AppLogger.w('AppReviewService: Native review not available on this device.');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('AppReviewService: Failed to process review logic', e, stackTrace);
    }
  }
}
