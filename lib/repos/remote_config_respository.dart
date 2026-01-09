import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:two_eight_two/models/models.dart';

class RemoteConfigRespository {
  final FirebaseRemoteConfig remoteConfig;

  RemoteConfigRespository(this.remoteConfig);

  Future<void> init() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 10),
    ));

    final defaultConfig = RemoteConfig.defaultConfig;

    await remoteConfig.setDefaults({
      RCFields.feedbackSurveyNumber: defaultConfig.feedbackSurveyNumber,
      RCFields.latestAppVersion: defaultConfig.latestAppVersion,
      RCFields.hardUpdateBuildNumber: defaultConfig.hardUpdateBuildNumber,
      RCFields.whatsNew: defaultConfig.whatsNew,
      RCFields.showPrivacyOption: defaultConfig.showPrivacyOption,
      RCFields.groupFilterNewIcon: defaultConfig.groupFilterNewIcon,
      RCFields.mapboxMapScreen: defaultConfig.mapboxMapScreen,
    });

    await remoteConfig.fetchAndActivate();
  }

  String getString(String key) => remoteConfig.getString(key);
  bool getBool(String key) => remoteConfig.getBool(key);
  int getInt(String key) => remoteConfig.getInt(key);
}
