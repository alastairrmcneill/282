import 'package:intl/intl.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class StartupOverlayPolicies {
  final RemoteConfigState _remoteConfig;
  final OverlayIntentState _overlayIntentState;
  final AppFlagsRepository _appFlagsRepository;
  final AppInfoRepository _appInfoRepository;

  const StartupOverlayPolicies(
    this._remoteConfig,
    this._overlayIntentState,
    this._appFlagsRepository,
    this._appInfoRepository,
  );

  void maybeEnqueueHardUpdate() {
    int currentBuildNumber = _appInfoRepository.buildNumber;
    int latestBuildNumber = _remoteConfig.config.hardUpdateBuildNumber;

    if (currentBuildNumber < latestBuildNumber) {
      _overlayIntentState.enqueue(HardUpdateDialogIntent());
    }
  }

  void maybeEnqueueSoftUpdate() {
    String appVersion = _appInfoRepository.version;
    String latestAppVersion = _remoteConfig.config.latestAppVersion;

    bool newVersionAvailable = _isVersionOlder(appVersion, latestAppVersion);

    if (!newVersionAvailable) return;

    String lastAppUpdateDialogDateString = _appFlagsRepository.lastAppUpdateDialogDate;

    DateTime lastAppUpdateDialogDate = DateFormat("dd/MM/yyyy").parse(lastAppUpdateDialogDateString);
    DateTime today = DateTime.now();

    if (today.difference(lastAppUpdateDialogDate).inDays < 1) return;

    String whatsNew = _remoteConfig.config.whatsNew;

    _overlayIntentState.enqueue(SoftUpdateDialogIntent(
      currentVersion: appVersion,
      latestVersion: latestAppVersion,
      whatsNew: whatsNew,
    ));
  }

  void maybeEnqueueWhatsNew() {
    String version = "1.2.6"; // TODO update this to the version you want to show a whats new for;
    bool showWhatsNewDialog = _appFlagsRepository.showWhatsNewDialog(version);

    String? firstAppVersion = _appFlagsRepository.firstAppVersion;

    if (firstAppVersion == null) {
      _appFlagsRepository.setFirstAppVersion(version);
      return;
    }

    if (firstAppVersion == version) return;

    if (showWhatsNewDialog) {
      _overlayIntentState.enqueue(WhatsNewDialogIntent(version: version));
    }
  }

  void maybeEnqueueAppSurvey() {
    int currentFeedbackSurveyNumber = _remoteConfig.config.feedbackSurveyNumber;

    int lastFeedbackSurveyNumber = _appFlagsRepository.lastFeedbackSurveyNumber;

    if (lastFeedbackSurveyNumber == -1) {
      _appFlagsRepository.setLastFeedbackSurveyNumber(currentFeedbackSurveyNumber);
      return;
    }

    if (currentFeedbackSurveyNumber > lastFeedbackSurveyNumber) {
      _overlayIntentState.enqueue(FeedbackSurveyIntent(surveyNumber: currentFeedbackSurveyNumber));
    }
  }

  bool _isVersionOlder(String version1, String version2) {
    // returns true if version1 is older than version2

    List<int> v1 = version1.split('.').map(int.parse).toList();
    List<int> v2 = version2.split('.').map(int.parse).toList();

    // Compare each component
    for (int i = 0; i < v1.length; i++) {
      if (v1[i] < v2[i]) return true; // version1 is older
      if (v1[i] > v2[i]) return false; // version1 is newer
    }
    return false;
  }
}
