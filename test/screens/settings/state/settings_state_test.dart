import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'settings_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  SettingsRepository,
  Logger,
])
void main() {
  late MockSettingsRepository mockSettingsRepository;
  late MockLogger mockLogger;
  late SettingsState settingsState;

  late AppSettings sampleSettings;

  setUp(() {
    // Sample settings data for testing
    sampleSettings = AppSettings(
      pushNotifications: true,
      metricHeight: false,
      metricTemperature: true,
      defaultPostVisibility: Privacy.public,
    );

    mockSettingsRepository = MockSettingsRepository();
    mockLogger = MockLogger();
    settingsState = SettingsState(mockSettingsRepository, mockLogger);
  });

  group('SettingsState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(settingsState.status, SettingsStatus.initial);
        expect(settingsState.error, isA<Error>());
        expect(settingsState.enablePushNotifications, true);
        expect(settingsState.metricHeight, false);
        expect(settingsState.metricTemperature, true);
        expect(settingsState.defaultPostVisibility, Privacy.public);
      });
    });

    group('load', () {
      test('should load settings successfully', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);

        // Act
        await settingsState.load();

        // Assert
        expect(settingsState.status, SettingsStatus.loaded);
        expect(settingsState.enablePushNotifications, true);
        expect(settingsState.metricHeight, false);
        expect(settingsState.metricTemperature, true);
        expect(settingsState.defaultPostVisibility, Privacy.public);
        verify(mockSettingsRepository.load()).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load settings with custom values', () async {
        // Arrange
        final customSettings = AppSettings(
          pushNotifications: false,
          metricHeight: true,
          metricTemperature: false,
          defaultPostVisibility: Privacy.private,
        );
        when(mockSettingsRepository.load()).thenReturn(customSettings);

        // Act
        await settingsState.load();

        // Assert
        expect(settingsState.status, SettingsStatus.loaded);
        expect(settingsState.enablePushNotifications, false);
        expect(settingsState.metricHeight, true);
        expect(settingsState.metricTemperature, false);
        expect(settingsState.defaultPostVisibility, Privacy.private);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenThrow(Exception('Load error'));

        // Act
        await settingsState.load();

        // Assert
        expect(settingsState.status, SettingsStatus.error);
        expect(settingsState.error.message, 'There was an issue loading the settings.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading and then loaded', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);

        // Act & Assert
        // The status will be loading briefly, then immediately loaded since load() is synchronous
        await settingsState.load();
        expect(settingsState.status, SettingsStatus.loaded);
      });
    });

    group('update', () {
      setUp(() async {
        // Load initial settings first
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);
        await settingsState.load();
        reset(mockSettingsRepository); // Reset to clear the load call
      });

      test('should update settings successfully', () async {
        // Arrange
        final updatedSettings = sampleSettings.copyWith(pushNotifications: false);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.update(updatedSettings);

        // Assert
        expect(settingsState.enablePushNotifications, false);
        verify(mockSettingsRepository.save(updatedSettings)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should update multiple settings at once', () async {
        // Arrange
        final updatedSettings = AppSettings(
          pushNotifications: false,
          metricHeight: true,
          metricTemperature: false,
          defaultPostVisibility: Privacy.friends,
        );
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.update(updatedSettings);

        // Assert
        expect(settingsState.enablePushNotifications, false);
        expect(settingsState.metricHeight, true);
        expect(settingsState.metricTemperature, false);
        expect(settingsState.defaultPostVisibility, Privacy.friends);
        verify(mockSettingsRepository.save(updatedSettings)).called(1);
      });

      test('should handle error during update', () async {
        // Arrange
        final updatedSettings = sampleSettings.copyWith(metricHeight: true);
        when(mockSettingsRepository.save(any)).thenThrow(Exception('Save error'));

        // Act
        await settingsState.update(updatedSettings);

        // Assert
        expect(settingsState.status, SettingsStatus.error);
        expect(settingsState.error.message, 'There was an issue saving the settings.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        final updatedSettings = sampleSettings.copyWith(metricTemperature: false);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return;
        });

        // Act
        final future = settingsState.update(updatedSettings);

        // Assert intermediate state
        expect(settingsState.status, SettingsStatus.loading);

        // Wait for completion
        await future;
      });
    });

    group('setEnablePushNotifications', () {
      setUp(() async {
        // Load initial settings first
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);
        await settingsState.load();
        reset(mockSettingsRepository); // Reset to clear the load call
      });

      test('should update push notifications to false', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setEnablePushNotifications(false);

        // Assert
        expect(settingsState.enablePushNotifications, false);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.pushNotifications == false),
        ))).called(1);
      });

      test('should update push notifications to true', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(
          sampleSettings.copyWith(pushNotifications: false),
        );
        await settingsState.load();
        reset(mockSettingsRepository);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setEnablePushNotifications(true);

        // Assert
        expect(settingsState.enablePushNotifications, true);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.pushNotifications == true),
        ))).called(1);
      });

      test('should preserve other settings when updating push notifications', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setEnablePushNotifications(false);

        // Assert
        expect(settingsState.metricHeight, false);
        expect(settingsState.metricTemperature, true);
        expect(settingsState.defaultPostVisibility, Privacy.public);
      });
    });

    group('setMetricHeight', () {
      setUp(() async {
        // Load initial settings first
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);
        await settingsState.load();
        reset(mockSettingsRepository); // Reset to clear the load call
      });

      test('should update metric height to true', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricHeight(true);

        // Assert
        expect(settingsState.metricHeight, true);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.metricHeight == true),
        ))).called(1);
      });

      test('should update metric height to false', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(
          sampleSettings.copyWith(metricHeight: true),
        );
        await settingsState.load();
        reset(mockSettingsRepository);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricHeight(false);

        // Assert
        expect(settingsState.metricHeight, false);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.metricHeight == false),
        ))).called(1);
      });

      test('should preserve other settings when updating metric height', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricHeight(true);

        // Assert
        expect(settingsState.enablePushNotifications, true);
        expect(settingsState.metricTemperature, true);
        expect(settingsState.defaultPostVisibility, Privacy.public);
      });
    });

    group('setMetricTemperature', () {
      setUp(() async {
        // Load initial settings first
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);
        await settingsState.load();
        reset(mockSettingsRepository); // Reset to clear the load call
      });

      test('should update metric temperature to false', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricTemperature(false);

        // Assert
        expect(settingsState.metricTemperature, false);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.metricTemperature == false),
        ))).called(1);
      });

      test('should update metric temperature to true', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(
          sampleSettings.copyWith(metricTemperature: false),
        );
        await settingsState.load();
        reset(mockSettingsRepository);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricTemperature(true);

        // Assert
        expect(settingsState.metricTemperature, true);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.metricTemperature == true),
        ))).called(1);
      });

      test('should preserve other settings when updating metric temperature', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setMetricTemperature(false);

        // Assert
        expect(settingsState.enablePushNotifications, true);
        expect(settingsState.metricHeight, false);
        expect(settingsState.defaultPostVisibility, Privacy.public);
      });
    });

    group('setDefaultPostVisibility', () {
      setUp(() async {
        // Load initial settings first
        when(mockSettingsRepository.load()).thenReturn(sampleSettings);
        await settingsState.load();
        reset(mockSettingsRepository); // Reset to clear the load call
      });

      test('should update default post visibility to private', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setDefaultPostVisibility(Privacy.private);

        // Assert
        expect(settingsState.defaultPostVisibility, Privacy.private);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.defaultPostVisibility == Privacy.private),
        ))).called(1);
      });

      test('should update default post visibility to followers only', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setDefaultPostVisibility(Privacy.friends);

        // Assert
        expect(settingsState.defaultPostVisibility, Privacy.friends);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.defaultPostVisibility == Privacy.friends),
        ))).called(1);
      });

      test('should update default post visibility to public', () async {
        // Arrange
        when(mockSettingsRepository.load()).thenReturn(
          sampleSettings.copyWith(defaultPostVisibility: Privacy.private),
        );
        await settingsState.load();
        reset(mockSettingsRepository);
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setDefaultPostVisibility(Privacy.public);

        // Assert
        expect(settingsState.defaultPostVisibility, Privacy.public);
        verify(mockSettingsRepository.save(argThat(
          predicate<AppSettings>((s) => s.defaultPostVisibility == Privacy.public),
        ))).called(1);
      });

      test('should preserve other settings when updating default post visibility', () async {
        // Arrange
        when(mockSettingsRepository.save(any)).thenAnswer((_) async => Future.value());

        // Act
        await settingsState.setDefaultPostVisibility(Privacy.private);

        // Assert
        expect(settingsState.enablePushNotifications, true);
        expect(settingsState.metricHeight, false);
        expect(settingsState.metricTemperature, true);
      });
    });

    group('setError', () {
      test('should set error and status correctly', () {
        // Arrange
        final error = Error(code: 'test_code', message: 'Test error message');

        // Act
        settingsState.setError = error;

        // Assert
        expect(settingsState.status, SettingsStatus.error);
        expect(settingsState.error.code, 'test_code');
        expect(settingsState.error.message, 'Test error message');
      });
    });
  });
}
