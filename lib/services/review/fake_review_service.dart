import '../app_logger.dart';
import 'review_service.dart';

class FakeReviewService implements ReviewService {
  int _fakeHarvestCount = 0;
  static const int _targetHarvestCount = 3;

  @override
  Future<void> checkAndRequestReview() async {
    _fakeHarvestCount++;
    AppLogger.i('FakeReviewService: Harvest count is now $_fakeHarvestCount');
    
    if (_fakeHarvestCount == _targetHarvestCount) {
      // In Beta/Test mode, we don't want to actually show the popup
      // or mess with SharedPreferences. We just log the trigger.
      AppLogger.i('FakeReviewService: [MOCK] Native app review popup triggered.');
    }
  }
}
