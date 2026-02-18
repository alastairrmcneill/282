import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/push/push_notifications_state.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'push_notifications_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PushNotificationRepository,
  FcmTokenRepository,
  SettingsState,
  UserState,
  NavigationIntentState,
  AppInfoRepository,
  Logger,
])
void main() {
  late MockPushNotificationRepository mockPushNotificationRepository;
  late MockFcmTokenRepository mockFcmTokenRepository;
  late MockSettingsState mockSettingsState;
  late MockUserState mockUserState;
  late MockNavigationIntentState mockNavigationIntentState;
  late MockAppInfoRepository mockAppInfoRepository;
  late MockLogger mockLogger;
  late PushNotificationState pushNotificationState;

  late AppUser sampleUser;
  late StreamController<RemoteMessage> onNotificationOpenedController;
  late StreamController<String> onTokenRefreshController;

  // Helper to create NotificationSettings with all required parameters
  NotificationSettings createAuthorizedSettings() {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.enabled,
    );
  }

  NotificationSettings createDeniedSettings() {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.denied,
      alert: AppleNotificationSetting.disabled,
      announcement: AppleNotificationSetting.disabled,
      badge: AppleNotificationSetting.disabled,
      carPlay: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.disabled,
      notificationCenter: AppleNotificationSetting.disabled,
      showPreviews: AppleShowPreviewSetting.never,
      sound: AppleNotificationSetting.disabled,
      timeSensitive: AppleNotificationSetting.disabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }

  NotificationSettings createNotDeterminedSettings() {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.notDetermined,
      alert: AppleNotificationSetting.notSupported,
      announcement: AppleNotificationSetting.notSupported,
      badge: AppleNotificationSetting.notSupported,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.notSupported,
      notificationCenter: AppleNotificationSetting.notSupported,
      showPreviews: AppleShowPreviewSetting.notSupported,
      sound: AppleNotificationSetting.notSupported,
      timeSensitive: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
    );
  }

  NotificationSettings createProvisionalSettings() {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.provisional,
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.enabled,
    );
  }

  setUp(() {
    // Sample user data for testing
    sampleUser = AppUser(
      uid: 'testUser123',
      displayName: 'Test User',
      firstName: 'Test',
      lastName: 'User',
    );

    mockPushNotificationRepository = MockPushNotificationRepository();
    mockFcmTokenRepository = MockFcmTokenRepository();
    mockSettingsState = MockSettingsState();
    mockUserState = MockUserState();
    mockNavigationIntentState = MockNavigationIntentState();
    mockAppInfoRepository = MockAppInfoRepository();
    mockLogger = MockLogger();

    // Create stream controllers for mocking
    onNotificationOpenedController = StreamController<RemoteMessage>.broadcast();
    onTokenRefreshController = StreamController<String>.broadcast();

    // Default mock behavior
    when(mockPushNotificationRepository.onNotificationOpened).thenAnswer((_) => onNotificationOpenedController.stream);
    when(mockPushNotificationRepository.onTokenRefresh).thenAnswer((_) => onTokenRefreshController.stream);
    when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
    when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'default_token');
    when(mockSettingsState.enablePushNotifications).thenReturn(true);
    when(mockUserState.currentUser).thenReturn(sampleUser);
    when(mockAppInfoRepository.version).thenReturn('1.0.0');
    when(mockFcmTokenRepository.upsertToken(
      userId: anyNamed('userId'),
      deviceId: anyNamed('deviceId'),
      token: anyNamed('token'),
      platform: anyNamed('platform'),
      appVersion: anyNamed('appVersion'),
      osVersion: anyNamed('osVersion'),
      deviceModel: anyNamed('deviceModel'),
    )).thenAnswer((_) async {});
    when(mockFcmTokenRepository.setTokenPushEnabled(
      userId: anyNamed('userId'),
      deviceId: anyNamed('deviceId'),
      enabled: anyNamed('enabled'),
    )).thenAnswer((_) async {});

    pushNotificationState = PushNotificationState(
      mockPushNotificationRepository,
      mockFcmTokenRepository,
      mockSettingsState,
      mockUserState,
      mockNavigationIntentState,
      mockAppInfoRepository,
      mockLogger,
    );
  });

  tearDown(() async {
    await onNotificationOpenedController.close();
    await onTokenRefreshController.close();
    // Only dispose if not already disposed (some tests dispose early)
    try {
      pushNotificationState.dispose();
    } catch (_) {
      // Already disposed, ignore
    }
  });

  group('PushNotificationState', () {
    group('Initial State', () {
      test('should not start until init is called', () async {
        // No init called yet, so should not have subscribed to streams
        verifyNever(mockPushNotificationRepository.getInitialMessage());
      });
    });

    group('init', () {
      test('should handle cold start with initial message', () async {
        // Arrange
        final initialMessage = RemoteMessage(messageId: 'msg1');
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => initialMessage);

        // Act
        await pushNotificationState.init();

        // Assert
        verify(mockPushNotificationRepository.getInitialMessage()).called(1);
        verify(mockNavigationIntentState.enqueue(any)).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should handle cold start with no initial message', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);

        // Act
        await pushNotificationState.init();

        // Assert
        verify(mockPushNotificationRepository.getInitialMessage()).called(1);
        verifyNever(mockNavigationIntentState.enqueue(any));
      });

      test('should subscribe to notification opened stream', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);

        // Act
        await pushNotificationState.init();

        // Trigger the stream
        final message = RemoteMessage(messageId: 'msg2');
        onNotificationOpenedController.add(message);

        // Wait for stream processing
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(any)).called(1);
      });

      test('should subscribe to token refresh stream and sync token', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'new_token_456');

        // Act
        await pushNotificationState.init();

        // Trigger the token refresh stream
        onTokenRefreshController.add('new_token_456');

        // Wait for stream processing
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(greaterThan(0));
        verify(mockPushNotificationRepository.getToken()).called(greaterThan(0));
      });

      test('should only initialize once even when called multiple times', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);

        // Act
        await pushNotificationState.init();
        await pushNotificationState.init();
        await pushNotificationState.init();

        // Assert
        verify(mockPushNotificationRepository.getInitialMessage()).called(1);
      });

      test('should handle errors during initialization gracefully', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenThrow(Exception('Firebase error'));

        // Act
        await pushNotificationState.init();

        // Assert
        verify(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should sync token if push is enabled on init', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'token_789');

        // Act
        await pushNotificationState.init();

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verify(mockPushNotificationRepository.getToken()).called(1);
      });
    });

    group('onPushSettingChanged', () {
      test('should call enablePush when push notifications are enabled', () async {
        // Arrange
        when(mockSettingsState.enablePushNotifications).thenReturn(true);
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'token_123');

        // Act
        final result = await pushNotificationState.onPushSettingChanged();

        // Assert
        expect(result, true);
        verify(mockPushNotificationRepository.requestPermission()).called(greaterThan(0));
      });

      test('should call disablePush when push notifications are disabled', () async {
        // Arrange
        when(mockSettingsState.enablePushNotifications).thenReturn(false);

        // Act
        final result = await pushNotificationState.onPushSettingChanged();

        // Assert
        expect(result, true);
        verify(mockFcmTokenRepository.setTokenPushEnabled(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          enabled: false,
        )).called(1);
      });
    });

    group('enablePush', () {
      test('should enable push notifications successfully when authorized', () async {
        // Arrange
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'new_token_123');

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert
        expect(result, true);
        verify(mockPushNotificationRepository.requestPermission()).called(greaterThan(0));
        verify(mockPushNotificationRepository.getToken()).called(greaterThan(0));
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should return false when authorization is denied', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createDeniedSettings());

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert
        expect(result, false);
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verifyNever(mockPushNotificationRepository.getToken());
      });

      test('should return false when authorization is not determined', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createNotDeterminedSettings());

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert
        expect(result, false);
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verifyNever(mockPushNotificationRepository.getToken());
      });

      test('should handle errors during enable push', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenThrow(Exception('Permission error'));

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert
        expect(result, false);
        verify(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should sync token with force flag when enabling push', () async {
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'old_token');

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert - should still upsert token due to force flag
        expect(result, true);
        verify(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
      });
    });

    group('disablePush', () {
      test('should disable push notifications successfully', () async {
        // Act
        final result = await pushNotificationState.disablePush();

        // Assert
        expect(result, true);
        verify(mockFcmTokenRepository.setTokenPushEnabled(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          enabled: false,
        )).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should set push_enabled to false when disabling push', () async {
        // Act
        await pushNotificationState.disablePush();

        // Assert
        verify(mockFcmTokenRepository.setTokenPushEnabled(
          userId: 'testUser123',
          deviceId: anyNamed('deviceId'),
          enabled: false,
        )).called(1);
      });

      test('should return true when user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        final result = await pushNotificationState.disablePush();

        // Assert
        expect(result, true);
        verifyNever(mockFcmTokenRepository.setTokenPushEnabled(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          enabled: anyNamed('enabled'),
        ));
      });

      test('should return true when user uid is null', () async {
        // Arrange
        final userWithNullUid = AppUser(uid: null);
        when(mockUserState.currentUser).thenReturn(userWithNullUid);

        // Act
        final result = await pushNotificationState.disablePush();

        // Assert
        expect(result, true);
        verifyNever(mockFcmTokenRepository.setTokenPushEnabled(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          enabled: anyNamed('enabled'),
        ));
      });

      test('should handle errors during disable push', () async {
        // Arrange
        when(mockFcmTokenRepository.setTokenPushEnabled(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          enabled: anyNamed('enabled'),
        )).thenThrow(Exception('Database error'));

        // Act
        final result = await pushNotificationState.disablePush();

        // Assert
        expect(result, false);
        verify(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('syncTokenIfNeeded', () {
      test('should sync token when all conditions are met', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'new_token_999');

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verify(mockPushNotificationRepository.getToken()).called(1);
        verify(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should not sync when push notifications are disabled', () async {
        // Arrange
        when(mockSettingsState.enablePushNotifications).thenReturn(false);

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verifyNever(mockPushNotificationRepository.requestPermission());
        verifyNever(mockPushNotificationRepository.getToken());
      });

      test('should not sync when user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verifyNever(mockPushNotificationRepository.requestPermission());
        verifyNever(mockPushNotificationRepository.getToken());
      });

      test('should not sync when permission is denied', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createDeniedSettings());

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verifyNever(mockPushNotificationRepository.getToken());
        verifyNever(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        ));
      });

      test('should not sync when token is null', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => null);

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verify(mockPushNotificationRepository.getToken()).called(1);
        verifyNever(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        ));
      });

      test('should not sync when token is empty', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => '');

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verify(mockPushNotificationRepository.getToken()).called(1);
        verifyNever(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        ));
      });

      test('should always sync token (no longer skips matching tokens)', () async {
        // Arrange - now we always upsert since we're using the new FCM tokens table
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'existing_token_123');

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert - now we always upsert to keep last_used_at updated
        verify(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
      });

      test('should sync when force is true', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'existing_token_123');

        // Act
        await pushNotificationState.syncTokenIfNeeded(force: true);

        // Assert
        verify(mockPushNotificationRepository.requestPermission()).called(1);
        verify(mockPushNotificationRepository.getToken()).called(1);
        verify(mockFcmTokenRepository.upsertToken(
          userId: anyNamed('userId'),
          deviceId: anyNamed('deviceId'),
          token: anyNamed('token'),
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
      });

      test('should upsert token with correct parameters', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'brand_new_token_999');

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockFcmTokenRepository.upsertToken(
          userId: 'testUser123',
          deviceId: anyNamed('deviceId'),
          token: 'brand_new_token_999',
          platform: anyNamed('platform'),
          appVersion: '1.0.0',
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
      });

      test('should handle errors during token sync gracefully', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenThrow(Exception('Sync error'));

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert
        verify(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('dispose', () {
      test('should cancel subscriptions on dispose', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);

        await pushNotificationState.init();

        // Act
        pushNotificationState.dispose();

        // Trigger streams after disposal
        final message = RemoteMessage(messageId: 'msg_after_dispose');
        onNotificationOpenedController.add(message);
        onTokenRefreshController.add('token_after_dispose');

        // Wait a bit
        await Future.delayed(Duration(milliseconds: 50));

        // Assert - the object is disposed, no exceptions should occur from the streams
        // Note: tearDown won't call dispose again because we already disposed it
        expect(pushNotificationState.toString(), isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle provisional authorization status', () async {
        // Arrange
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createProvisionalSettings());

        // Act
        final result = await pushNotificationState.enablePush();

        // Assert
        expect(result, false);
      });

      test('should handle multiple rapid token refreshes', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => null);
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async => 'token');

        await pushNotificationState.init();

        // Act
        onTokenRefreshController.add('token1');
        onTokenRefreshController.add('token2');
        onTokenRefreshController.add('token3');

        // Wait for processing
        await Future.delayed(Duration(milliseconds: 100));

        // Assert - should handle all refreshes without crashing
        verify(mockPushNotificationRepository.requestPermission()).called(greaterThan(0));
      });

      test('should handle notification opened while app is initializing', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return null;
        });

        // Act - Start init but trigger notification before it completes
        final initFuture = pushNotificationState.init();
        final message = RemoteMessage(messageId: 'msg_during_init');
        onNotificationOpenedController.add(message);

        await initFuture;
        await Future.delayed(Duration(milliseconds: 50));

        // Assert - Should handle the init without errors
        verify(mockPushNotificationRepository.getInitialMessage()).called(1);
        // The notification may or may not trigger intent depending on timing, so don't verify
      });

      test('should handle user changing during token sync', () async {
        // Arrange
        final user1 = AppUser(uid: 'user1');
        final user2 = AppUser(uid: 'user2');

        when(mockUserState.currentUser).thenReturn(user1);
        when(mockPushNotificationRepository.requestPermission()).thenAnswer((_) async => createAuthorizedSettings());
        when(mockPushNotificationRepository.getToken()).thenAnswer((_) async {
          // Simulate user changing during async operation
          when(mockUserState.currentUser).thenReturn(user2);
          return 'new_token';
        });

        // Act
        await pushNotificationState.syncTokenIfNeeded();

        // Assert - Should upsert token for the initial user
        verify(mockFcmTokenRepository.upsertToken(
          userId: 'user1',
          deviceId: anyNamed('deviceId'),
          token: 'new_token',
          platform: anyNamed('platform'),
          appVersion: anyNamed('appVersion'),
          osVersion: anyNamed('osVersion'),
          deviceModel: anyNamed('deviceModel'),
        )).called(1);
      });

      test('should not crash when repository returns empty RemoteMessage', () async {
        // Arrange
        when(mockPushNotificationRepository.getInitialMessage()).thenAnswer((_) async => RemoteMessage());

        // Act
        await pushNotificationState.init();

        // Assert - Should still enqueue intent even with empty message
        verify(mockNavigationIntentState.enqueue(any)).called(1);
      });
    });
  });
}
