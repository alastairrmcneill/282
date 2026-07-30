import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print("🚀 ~ AnalyticsService ~ logEvent: $name : $props");
      }
      await _mixpanel.track(name, properties: props);
    } catch (e, st) {
      _logger.error('Analytics.track failed: $name, error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> identify(String userId) async {
    try {
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

  @override
  Future<void> registerSuperProperty(String key, Object? value) async {
    try {
      await _mixpanel.registerSuperProperties({key: value});
    } catch (e, st) {
      _logger.error('Analytics.registerSuperProperty failed: key=$key, error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> setProfileProperties(Map<String, Object?> props) async {
    try {
      final people = _mixpanel.getPeople();
      props.forEach(people.set);
    } catch (e, st) {
      _logger.error('Analytics.setProfileProperties failed: error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> setProfilePropertiesOnce(Map<String, Object?> props) async {
    try {
      final people = _mixpanel.getPeople();
      props.forEach(people.setOnce);
    } catch (e, st) {
      _logger.error('Analytics.setProfilePropertiesOnce failed: error=$e', stackTrace: st);
    }
  }

  @override
  Future<void> incrementProfileProperty(String prop, double by) async {
    try {
      _mixpanel.getPeople().increment(prop, by);
    } catch (e, st) {
      _logger.error('Analytics.incrementProfileProperty failed: prop=$prop, error=$e', stackTrace: st);
    }
  }
}
