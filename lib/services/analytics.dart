import 'package:beaverlog_flutter/beaverlog_flutter.dart';

enum AnalyticsEvent {
  takePicture,
  onboardingStarted,
  scanStarted,
  scanCompleted,
  scanFailed,
  foodAnalysisCompleted,
  foodAnalysisFailed,
  onboardingCompleted,
  symptomsUpdated,
  reviewPromptShown,
  reviewLeft,
  manualEntryUsed,
  manualEntry,
  ingredientListExpanded,
}

class Analytics {
  static void track(AnalyticsEvent event, [Map<String, Object>? metadata]) {
    BeaverLog().event(
      eventName: event.name,
      meta: metadata,
    );
  }
}