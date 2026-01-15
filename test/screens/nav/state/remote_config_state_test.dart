import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/nav/state/remote_config_state.dart';

import 'remote_config_state_test.mocks.dart';

@GenerateMocks([
  RemoteConfigRespository,
  Logger,
])
void main() {
  late MockRemoteConfigRespository mockRemoteConfigRespository;
  late MockLogger mockLogger;
  late RemoteConfigState remoteConfigState;

  setUp(() {
    mockRemoteConfigRespository = MockRemoteConfigRespository();
    mockLogger = MockLogger();

    remoteConfigState = RemoteConfigState(
      mockRemoteConfigRespository,
      mockLogger,
    );
  });

  group('RemoteConfigState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(remoteConfigState.status, RemoteConfigStatus.initial);
        expect(remoteConfigState.error, isA<Error>());
        expect(remoteConfigState.error.code, isEmpty);
        expect(remoteConfigState.error.message, isEmpty);

        final defaultConfig = RemoteConfig.defaultConfig;
        expect(remoteConfigState.config.feedbackSurveyNumber, defaultConfig.feedbackSurveyNumber);
        expect(remoteConfigState.config.latestAppVersion, defaultConfig.latestAppVersion);
        expect(remoteConfigState.config.hardUpdateBuildNumber, defaultConfig.hardUpdateBuildNumber);
        expect(remoteConfigState.config.whatsNew, defaultConfig.whatsNew);
        expect(remoteConfigState.config.showPrivacyOption, defaultConfig.showPrivacyOption);
        expect(remoteConfigState.config.groupFilterNewIcon, defaultConfig.groupFilterNewIcon);
        expect(remoteConfigState.config.mapboxMapScreen, defaultConfig.mapboxMapScreen);
      });
    });

    group('init', () {
      void stubSnapshot({
        required int feedbackSurveyNumber,
        required String latestAppVersion,
        required int hardUpdateBuildNumber,
        required String whatsNew,
        required bool showPrivacyOption,
        required bool groupFilterNewIcon,
        required bool mapboxMapScreen,
      }) {
        when(mockRemoteConfigRespository.getInt(RCFields.feedbackSurveyNumber)).thenReturn(feedbackSurveyNumber);
        when(mockRemoteConfigRespository.getString(RCFields.latestAppVersion)).thenReturn(latestAppVersion);
        when(mockRemoteConfigRespository.getInt(RCFields.hardUpdateBuildNumber)).thenReturn(hardUpdateBuildNumber);
        when(mockRemoteConfigRespository.getString(RCFields.whatsNew)).thenReturn(whatsNew);
        when(mockRemoteConfigRespository.getBool(RCFields.showPrivacyOption)).thenReturn(showPrivacyOption);
        when(mockRemoteConfigRespository.getBool(RCFields.groupFilterNewIcon)).thenReturn(groupFilterNewIcon);
        when(mockRemoteConfigRespository.getBool(RCFields.mapboxMapScreen)).thenReturn(mapboxMapScreen);
      }

      test('should set loading then loaded and read snapshot on success', () async {
        // Arrange
        when(mockRemoteConfigRespository.init()).thenAnswer((_) async {});
        stubSnapshot(
          feedbackSurveyNumber: 3,
          latestAppVersion: '2.0.0',
          hardUpdateBuildNumber: 42,
          whatsNew: 'New stuff',
          showPrivacyOption: false,
          groupFilterNewIcon: true,
          mapboxMapScreen: true,
        );

        final statuses = <RemoteConfigStatus>[];
        remoteConfigState.addListener(() => statuses.add(remoteConfigState.status));

        // Act
        await remoteConfigState.init();

        // Assert
        expect(statuses, [RemoteConfigStatus.loading, RemoteConfigStatus.loaded]);
        expect(remoteConfigState.status, RemoteConfigStatus.loaded);
        expect(remoteConfigState.error.message, isEmpty);

        expect(remoteConfigState.config.feedbackSurveyNumber, 3);
        expect(remoteConfigState.config.latestAppVersion, '2.0.0');
        expect(remoteConfigState.config.hardUpdateBuildNumber, 42);
        expect(remoteConfigState.config.whatsNew, 'New stuff');
        expect(remoteConfigState.config.showPrivacyOption, false);
        expect(remoteConfigState.config.groupFilterNewIcon, true);
        expect(remoteConfigState.config.mapboxMapScreen, true);

        verifyInOrder([
          mockRemoteConfigRespository.init(),
          mockRemoteConfigRespository.getInt(RCFields.feedbackSurveyNumber),
          mockRemoteConfigRespository.getString(RCFields.latestAppVersion),
          mockRemoteConfigRespository.getInt(RCFields.hardUpdateBuildNumber),
          mockRemoteConfigRespository.getString(RCFields.whatsNew),
          mockRemoteConfigRespository.getBool(RCFields.showPrivacyOption),
          mockRemoteConfigRespository.getBool(RCFields.groupFilterNewIcon),
          mockRemoteConfigRespository.getBool(RCFields.mapboxMapScreen),
        ]);

        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should set loading then error, log, and still read snapshot on failure', () async {
        // Arrange
        final exception = Exception('Remote config init failed');
        when(mockRemoteConfigRespository.init()).thenThrow(exception);
        stubSnapshot(
          feedbackSurveyNumber: 1,
          latestAppVersion: '1.2.3',
          hardUpdateBuildNumber: 10,
          whatsNew: 'Hello',
          showPrivacyOption: true,
          groupFilterNewIcon: false,
          mapboxMapScreen: false,
        );

        final statuses = <RemoteConfigStatus>[];
        remoteConfigState.addListener(() => statuses.add(remoteConfigState.status));

        // Act
        await remoteConfigState.init();

        // Assert
        expect(statuses, [RemoteConfigStatus.loading, RemoteConfigStatus.error]);
        expect(remoteConfigState.status, RemoteConfigStatus.error);
        expect(remoteConfigState.error.message, exception.toString());

        // Still reads snapshot (so dependent code has sane defaults)
        expect(remoteConfigState.config.feedbackSurveyNumber, 1);
        expect(remoteConfigState.config.latestAppVersion, '1.2.3');
        expect(remoteConfigState.config.hardUpdateBuildNumber, 10);
        expect(remoteConfigState.config.whatsNew, 'Hello');
        expect(remoteConfigState.config.showPrivacyOption, true);
        expect(remoteConfigState.config.groupFilterNewIcon, false);
        expect(remoteConfigState.config.mapboxMapScreen, false);

        verify(mockLogger.error(
          'Failed to initialize remote config: $exception',
          stackTrace: anyNamed('stackTrace'),
        )).called(1);

        verify(mockRemoteConfigRespository.getInt(RCFields.feedbackSurveyNumber)).called(1);
        verify(mockRemoteConfigRespository.getString(RCFields.latestAppVersion)).called(1);
        verify(mockRemoteConfigRespository.getInt(RCFields.hardUpdateBuildNumber)).called(1);
        verify(mockRemoteConfigRespository.getString(RCFields.whatsNew)).called(1);
        verify(mockRemoteConfigRespository.getBool(RCFields.showPrivacyOption)).called(1);
        verify(mockRemoteConfigRespository.getBool(RCFields.groupFilterNewIcon)).called(1);
        verify(mockRemoteConfigRespository.getBool(RCFields.mapboxMapScreen)).called(1);
      });

      test('should notify listeners exactly twice (loading + final)', () async {
        // Arrange
        when(mockRemoteConfigRespository.init()).thenAnswer((_) async {});
        stubSnapshot(
          feedbackSurveyNumber: 0,
          latestAppVersion: '1.0.0',
          hardUpdateBuildNumber: 0,
          whatsNew: 'x',
          showPrivacyOption: true,
          groupFilterNewIcon: true,
          mapboxMapScreen: false,
        );

        var notificationCount = 0;
        remoteConfigState.addListener(() => notificationCount++);

        // Act
        await remoteConfigState.init();

        // Assert
        expect(notificationCount, 2);
      });
    });
  });
}
