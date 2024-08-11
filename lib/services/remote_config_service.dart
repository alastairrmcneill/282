import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:two_eight_two/services/log_service.dart';
import 'package:two_eight_two/services/services.dart';

class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 10),
    ));

    await _remoteConfig.setDefaults(const {
      RCFields.feedbackSurveyDate: "01/01/2000",
      RCFields.latestAppVersion: "1.0.0",
      RCFields.whatsNew: "No new features this time. We are working hard to bring you new features soon.",
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      Log.error('Could not fetch and activate remote config: $e');
    }
  }

  static getString(String key) {
    return _remoteConfig.getString(key);
  }

  static getBool(String key) {
    return _remoteConfig.getBool(key);
  }
}

class RCFields {
  static const feedbackSurveyDate = "feedback_survey_date";
  static const latestAppVersion = "latest_app_version";
  static const whatsNew = "whats_new";
}
