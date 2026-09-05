/// The deep module seam for the App Review mechanism.
/// The interface completely hides whether we are using native APIs,
/// faking it for tests, or tracking local counters for delays.
abstract class ReviewService {
  /// Evaluates the internal business rules (e.g., harvest count)
  /// and requests an app review from the OS if the conditions are met.
  Future<void> checkAndRequestReview();
}
