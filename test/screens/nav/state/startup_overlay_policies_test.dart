import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/nav/state/overlay_intent_state.dart';
import 'package:two_eight_two/screens/nav/state/remote_config_state.dart';
import 'package:two_eight_two/screens/nav/state/startup_overlay_policies.dart';

import 'startup_overlay_policies_test.mocks.dart';

@GenerateMocks([
  RemoteConfigState,
  OverlayIntentState,
  AppFlagsRepository,
  AppInfoRepository,
])
void main() {
  late MockRemoteConfigState mockRemoteConfigState;
  late MockOverlayIntentState mockOverlayIntentState;
  late MockAppFlagsRepository mockAppFlagsRepository;
  late MockAppInfoRepository mockAppInfoRepository;
  late StartupOverlayPolicies policies;

  setUp(() {
    mockRemoteConfigState = MockRemoteConfigState();
    mockOverlayIntentState = MockOverlayIntentState();
    mockAppFlagsRepository = MockAppFlagsRepository();
    mockAppInfoRepository = MockAppInfoRepository();

    policies = StartupOverlayPolicies(
      mockRemoteConfigState,
      mockOverlayIntentState,
      mockAppFlagsRepository,
      mockAppInfoRepository,
    );

    // Default remote config to something sensible for tests.
    when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
      feedbackSurveyNumber: 1,
      latestAppVersion: '1.0.0',
      hardUpdateBuildNumber: 0,
      whatsNew: 'New features',
      showPrivacyOption: true,
      groupFilterNewIcon: true,
      mapboxMapScreen: false,
    ));

    // `maybeEnqueueWhatsNew()` calls this before checking `firstAppVersion`.
    when(mockAppFlagsRepository.showWhatsNewDialog(any)).thenReturn(true);
  });

  group('StartupOverlayPolicies', () {
    group('maybeEnqueueHardUpdate', () {
      test('should enqueue HardUpdateDialogIntent when current build is lower', () {
        // Arrange
        when(mockAppInfoRepository.buildNumber).thenReturn(100);
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 101,
          whatsNew: 'New features',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        // Act
        policies.maybeEnqueueHardUpdate();

        // Assert
        verify(
          mockOverlayIntentState.enqueue(
            argThat(isA<HardUpdateDialogIntent>()),
          ),
        ).called(1);
      });

      test('should not enqueue when current build is equal', () {
        // Arrange
        when(mockAppInfoRepository.buildNumber).thenReturn(101);
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 101,
          whatsNew: 'New features',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        // Act
        policies.maybeEnqueueHardUpdate();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should not enqueue when current build is higher', () {
        // Arrange
        when(mockAppInfoRepository.buildNumber).thenReturn(200);
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 101,
          whatsNew: 'New features',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        // Act
        policies.maybeEnqueueHardUpdate();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });
    });

    group('maybeEnqueueSoftUpdate', () {
      test('should not enqueue when no newer version is available', () {
        // Arrange
        when(mockAppInfoRepository.version).thenReturn('1.2.3');
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.2.3',
          hardUpdateBuildNumber: 0,
          whatsNew: 'Release notes',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        // Act
        policies.maybeEnqueueSoftUpdate();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should not enqueue when version is older but dialog was shown today', () {
        // Arrange
        when(mockAppInfoRepository.version).thenReturn('1.0.0');
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.1.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'Release notes',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
        when(mockAppFlagsRepository.lastAppUpdateDialogDate).thenReturn(today);

        // Act
        policies.maybeEnqueueSoftUpdate();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should enqueue SoftUpdateDialogIntent when version is older and last shown is old enough', () {
        // Arrange
        when(mockAppInfoRepository.version).thenReturn('1.0.0');
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.1.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'Release notes',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        final oldEnough = DateFormat('dd/MM/yyyy').format(
          DateTime.now().subtract(const Duration(days: 2)),
        );
        when(mockAppFlagsRepository.lastAppUpdateDialogDate).thenReturn(oldEnough);

        // Act
        policies.maybeEnqueueSoftUpdate();

        // Assert
        verify(
          mockOverlayIntentState.enqueue(
            argThat(
              isA<SoftUpdateDialogIntent>()
                  .having((i) => i.currentVersion, 'currentVersion', '1.0.0')
                  .having((i) => i.latestVersion, 'latestVersion', '1.1.0')
                  .having((i) => i.whatsNew, 'whatsNew', 'Release notes'),
            ),
          ),
        ).called(1);
      });

      test('should treat 1.2.0 as older than 1.10.0 and enqueue when allowed by date', () {
        // Arrange
        when(mockAppInfoRepository.version).thenReturn('1.2.0');
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.10.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'Big update',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));

        final oldEnough = DateFormat('dd/MM/yyyy').format(
          DateTime.now().subtract(const Duration(days: 2)),
        );
        when(mockAppFlagsRepository.lastAppUpdateDialogDate).thenReturn(oldEnough);

        // Act
        policies.maybeEnqueueSoftUpdate();

        // Assert
        verify(
          mockOverlayIntentState.enqueue(
            argThat(
              isA<SoftUpdateDialogIntent>()
                  .having((i) => i.currentVersion, 'currentVersion', '1.2.0')
                  .having((i) => i.latestVersion, 'latestVersion', '1.10.0')
                  .having((i) => i.whatsNew, 'whatsNew', 'Big update'),
            ),
          ),
        ).called(1);
      });
    });

    group('maybeEnqueueWhatsNew', () {
      const version = '1.2.6';

      test('should set firstAppVersion and not enqueue when firstAppVersion is null', () {
        // Arrange
        when(mockAppFlagsRepository.firstAppVersion).thenReturn(null);

        // Act
        policies.maybeEnqueueWhatsNew();

        // Assert
        verify(mockAppFlagsRepository.setFirstAppVersion(version)).called(1);
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should not enqueue when firstAppVersion matches version', () {
        // Arrange
        when(mockAppFlagsRepository.firstAppVersion).thenReturn(version);

        // Act
        policies.maybeEnqueueWhatsNew();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
        verifyNever(mockAppFlagsRepository.setFirstAppVersion(any));
      });

      test('should not enqueue when showWhatsNewDialog is false', () {
        // Arrange
        when(mockAppFlagsRepository.firstAppVersion).thenReturn('0.9.0');
        when(mockAppFlagsRepository.showWhatsNewDialog(version)).thenReturn(false);

        // Act
        policies.maybeEnqueueWhatsNew();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should enqueue WhatsNewDialogIntent when showWhatsNewDialog is true and firstAppVersion differs', () {
        // Arrange
        when(mockAppFlagsRepository.firstAppVersion).thenReturn('0.9.0');
        when(mockAppFlagsRepository.showWhatsNewDialog(version)).thenReturn(true);

        // Act
        policies.maybeEnqueueWhatsNew();

        // Assert
        verify(
          mockOverlayIntentState.enqueue(
            argThat(
              isA<WhatsNewDialogIntent>().having((i) => i.version, 'version', version),
            ),
          ),
        ).called(1);
      });
    });

    group('maybeEnqueueAppSurvey', () {
      test('should persist survey number and not enqueue when lastFeedbackSurveyNumber is -1', () {
        // Arrange
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 5,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'x',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));
        when(mockAppFlagsRepository.lastFeedbackSurveyNumber).thenReturn(-1);

        // Act
        policies.maybeEnqueueAppSurvey();

        // Assert
        verify(mockAppFlagsRepository.setLastFeedbackSurveyNumber(5)).called(1);
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should not enqueue when current survey number is not greater than last', () {
        // Arrange
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 5,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'x',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));
        when(mockAppFlagsRepository.lastFeedbackSurveyNumber).thenReturn(5);

        // Act
        policies.maybeEnqueueAppSurvey();

        // Assert
        verifyNever(mockOverlayIntentState.enqueue(any));
      });

      test('should enqueue FeedbackSurveyIntent when current survey number is greater than last', () {
        // Arrange
        when(mockRemoteConfigState.config).thenReturn(const RemoteConfig(
          feedbackSurveyNumber: 6,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'x',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        ));
        when(mockAppFlagsRepository.lastFeedbackSurveyNumber).thenReturn(5);

        // Act
        policies.maybeEnqueueAppSurvey();

        // Assert
        verify(
          mockOverlayIntentState.enqueue(
            argThat(
              isA<FeedbackSurveyIntent>().having((i) => i.surveyNumber, 'surveyNumber', 6),
            ),
          ),
        ).called(1);
      });
    });
  });
}
