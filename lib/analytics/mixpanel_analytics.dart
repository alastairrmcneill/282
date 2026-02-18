import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:two_eight_two/logging/logging.dart';

import 'analytics_base.dart';

class MixpanelAnalytics implements Analytics {
  final Mixpanel _mixpanel;
  final Logger _logger;
  MixpanelAnalytics(this._mixpanel, this._logger);

  @override
  Future<void> track(String name, {Map<String, Object?>? props}) async {
    try {
      print("🚀 ~ AnalyticsService ~ logEvent: $name : $props");
      await _mixpanel.track(name, properties: props);
    } catch (e, st) {
      _logger.error('Analytics.track failed: $name, error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> identify(String userId) async {
    try {
      var annonId = await _mixpanel.getDistinctId();
      _mixpanel.alias(userId, annonId);
      await _mixpanel.identify(userId);
    } catch (e, st) {
      _logger.error('Analytics.identify failed: userId=$userId, error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _mixpanel.reset();
    } catch (e, st) {
      _logger.error('Analytics.reset failed: error=$e', stackTrace: st);
    }
  }
}
