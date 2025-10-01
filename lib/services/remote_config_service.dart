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
      RCFields.feedbackSurveyNumber: 0,
      RCFields.latestAppVersion: "1.0.0",
      RCFields.hardUpdateBuildNumber: 0,
      RCFields.whatsNew: "No new features this time. We are working hard to bring you new features soon.",
      RCFields.showPrivacyOption: true,
      RCFields.groupFilterNewIcon: true,
      RCFields.mapboxMapScreen: false,
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

  static getInt(String key) {
    return _remoteConfig.getInt(key);
  }
}

class RCFields {
  static const feedbackSurveyNumber = "feedback_survey_number";
  static const latestAppVersion = "latest_app_version";
  static const hardUpdateBuildNumber = "hard_update_build_number";
  static const whatsNew = "whats_new";
  static const showPrivacyOption = "show_privacy_option";
  static const groupFilterNewIcon = "group_filter_new_icon";
  static const mapboxMapScreen = "mapbox_map_screen";
}
