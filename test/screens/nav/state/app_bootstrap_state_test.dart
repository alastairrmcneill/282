import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/screens/nav/state/startup_overlay_policies.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'app_bootstrap_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  RemoteConfigState,
  DeepLinkState,
  SettingsState,
  AuthState,
  UserState,
  MunroState,
  MunroCompletionState,
  SavedListState,
  PushNotificationState,
  StartupOverlayPolicies,
  FlavorState,
  Logger,
])
void main() {
  late MockRemoteConfigState mockRemoteConfigState;
  late MockDeepLinkState mockDeepLinkState;
  late MockSettingsState mockSettingsState;
  late MockAuthState mockAuthState;
  late MockUserState mockUserState;
  late MockMunroState mockMunroState;
  late MockMunroCompletionState mockMunroCompletionState;
  late MockSavedListState mockSavedListState;
  late MockFlavorState mockFlavorState;
  late MockPushNotificationState mockPushNotificationState;
  late StartupOverlayPolicies mockStartupOverlayPolicies;
  late MockLogger mockLogger;
  late AppBootstrapState appBootstrapState;

  setUp(() {
    mockRemoteConfigState = MockRemoteConfigState();
    mockDeepLinkState = MockDeepLinkState();
    mockSettingsState = MockSettingsState();
    mockAuthState = MockAuthState();
    mockUserState = MockUserState();
    mockMunroState = MockMunroState();
    mockMunroCompletionState = MockMunroCompletionState();
    mockSavedListState = MockSavedListState();
    mockPushNotificationState = MockPushNotificationState();
    mockStartupOverlayPolicies = MockStartupOverlayPolicies();
    mockFlavorState = MockFlavorState();
    when(mockFlavorState.environment).thenReturn(AppEnvironment.dev);
    mockLogger = MockLogger();
    appBootstrapState = AppBootstrapState(
      mockRemoteConfigState,
      mockDeepLinkState,
      mockSettingsState,
      mockAuthState,
      mockUserState,
      mockMunroState,
      mockMunroCompletionState,
      mockSavedListState,
      mockPushNotificationState,
      mockStartupOverlayPolicies,
      mockFlavorState,
      mockLogger,
    );
  });

  group('AppBootstrapState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(appBootstrapState.status, AppBootstrapStatus.initial);
        expect(appBootstrapState.error, isNull);
        expect(appBootstrapState.isReady, false);
      });
    });

    group('init', () {
      test('should initialize successfully when user is not authenticated', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        expect(appBootstrapState.error, isNull);
        expect(appBootstrapState.isReady, true);
        verify(mockRemoteConfigState.init()).called(1);
        verify(mockSettingsState.load()).called(1);
        verify(mockMunroState.loadMunros()).called(1);
        verifyNever(mockUserState.readUser(uid: anyNamed('uid')));
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
        verifyNever(mockSavedListState.readUserSavedLists());
        verifyNever(mockUserState.loadBlockedUsers());
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));

        // Verify startup overlay policies are called
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(1);
      });

      test('should initialize successfully when user is authenticated', () async {
        // Arrange
        const testUid = 'testUser123';
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        expect(appBootstrapState.error, isNull);
        expect(appBootstrapState.isReady, true);
        verify(mockRemoteConfigState.init()).called(1);
        verify(mockSettingsState.load()).called(1);
        verify(mockMunroState.loadMunros()).called(1);
        verify(mockUserState.readUser(uid: testUid)).called(1);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
        verify(mockSavedListState.readUserSavedLists()).called(1);
        verify(mockUserState.loadBlockedUsers()).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));

        // Verify startup overlay policies are called
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(1);
      });

      test('should not initialize twice if already started', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();
        await appBootstrapState.init(); // Second call

        // Assert
        verify(mockRemoteConfigState.init()).called(1);
        verify(mockSettingsState.load()).called(1);
        verify(mockMunroState.loadMunros()).called(1);
      });

      test('should handle error during remote config initialization', () async {
        // Arrange
        final testError = Exception('Remote config error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);

        // Verify startup overlay policies are NOT called on error
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueHardUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueWhatsNew());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueAppSurvey());
      });

      test('should handle error during settings load', () async {
        // Arrange
        final testError = Exception('Settings load error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenThrow(testError);
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during munros load', () async {
        // Arrange
        final testError = Exception('Munros load error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenThrow(testError);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during user read', () async {
        // Arrange
        const testUid = 'testUser123';
        final testError = Exception('User read error');
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenThrow(testError);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockUserState.readUser(uid: testUid)).called(1);
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
        verifyNever(mockSavedListState.readUserSavedLists());
        verifyNever(mockUserState.loadBlockedUsers());
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during munro completions load', () async {
        // Arrange
        const testUid = 'testUser123';
        final testError = Exception('Munro completions error');
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenThrow(testError);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
        verifyNever(mockSavedListState.readUserSavedLists());
        verifyNever(mockUserState.loadBlockedUsers());
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during saved lists load', () async {
        // Arrange
        const testUid = 'testUser123';
        final testError = Exception('Saved lists error');
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenThrow(testError);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockSavedListState.readUserSavedLists()).called(1);
        verifyNever(mockUserState.loadBlockedUsers());
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during blocked users load', () async {
        // Arrange
        const testUid = 'testUser123';
        final testError = Exception('Blocked users error');
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenThrow(testError);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        expect(appBootstrapState.error, testError);
        expect(appBootstrapState.isReady, false);
        verify(mockUserState.loadBlockedUsers()).called(1);
        verify(mockLogger.error(any, error: testError, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return Future.value();
        });
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        final future = appBootstrapState.init();

        // Assert intermediate state
        expect(appBootstrapState.status, AppBootstrapStatus.loading);
        expect(appBootstrapState.isReady, false);

        // Wait for completion
        await future;
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        expect(appBootstrapState.isReady, true);
      });

      test('should clear error on successful initialization', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.error, isNull);
      });
    });

    group('retry', () {
      test('should reset started flag and call init again', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Initial init
        await appBootstrapState.init();

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        // Should be called twice: once for init, once for retry
        verify(mockRemoteConfigState.init()).called(2);
        verify(mockSettingsState.load()).called(2);
        verify(mockMunroState.loadMunros()).called(2);
      });

      test('should retry after error', () async {
        // Arrange
        final testError = Exception('First attempt error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Initial failed attempt
        await appBootstrapState.init();
        expect(appBootstrapState.status, AppBootstrapStatus.error);

        // Now make it succeed
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        expect(appBootstrapState.error, isNull);
        expect(appBootstrapState.isReady, true);
      });

      test('should allow retry from ready state', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Initial successful init
        await appBootstrapState.init();
        expect(appBootstrapState.status, AppBootstrapStatus.ready);

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        verify(mockRemoteConfigState.init()).called(2);
        verify(mockSettingsState.load()).called(2);
        verify(mockMunroState.loadMunros()).called(2);
      });
    });

    group('isReady getter', () {
      test('should return true when status is ready', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.isReady, true);
      });

      test('should return false when status is initial', () {
        expect(appBootstrapState.isReady, false);
      });

      test('should return false when status is loading', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return Future.value();
        });
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        final future = appBootstrapState.init();

        // Assert
        expect(appBootstrapState.isReady, false);

        await future;
      });

      test('should return false when status is error', () async {
        // Arrange
        final testError = Exception('Test error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.isReady, false);
      });
    });

    group('Edge Cases', () {
      test('should handle empty uid string', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn('');
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        // Empty string is truthy, so user-specific calls should be made
        verify(mockUserState.readUser(uid: '')).called(1);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
        verify(mockSavedListState.readUserSavedLists()).called(1);
        verify(mockUserState.loadBlockedUsers()).called(1);
      });

      test('should handle multiple retries', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();
        await appBootstrapState.retry();
        await appBootstrapState.retry();
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        // Should be called 4 times: once for init, three for retries
        verify(mockRemoteConfigState.init()).called(4);
        verify(mockSettingsState.load()).called(4);
        verify(mockMunroState.loadMunros()).called(4);
      });

      test('should handle all parallel operations completing successfully', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        var remoteConfigCalled = false;
        var settingsCalled = false;
        var munrosCalled = false;

        when(mockRemoteConfigState.init()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          remoteConfigCalled = true;
          return Future.value();
        });
        when(mockSettingsState.load()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 30));
          settingsCalled = true;
          return Future.value();
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 20));
          munrosCalled = true;
          return Future.value();
        });

        // Act
        await appBootstrapState.init();

        // Assert
        expect(remoteConfigCalled, true);
        expect(settingsCalled, true);
        expect(munrosCalled, true);
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
      });

      test('should handle user becoming authenticated between retries', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // First init without user
        await appBootstrapState.init();
        verifyNever(mockUserState.readUser(uid: anyNamed('uid')));

        // Now user is authenticated
        const testUid = 'newUser123';
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        verify(mockUserState.readUser(uid: testUid)).called(1);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
        verify(mockSavedListState.readUserSavedLists()).called(1);
        verify(mockUserState.loadBlockedUsers()).called(1);
      });

      test('should handle user becoming unauthenticated between retries', () async {
        // Arrange
        const testUid = 'testUser123';
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenAnswer((_) async => Future.value());

        // First init with user
        await appBootstrapState.init();
        verify(mockUserState.readUser(uid: testUid)).called(1);

        // Now user is not authenticated
        when(mockAuthState.currentUserId).thenReturn(null);

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        // User-specific calls should still only have been made once (during first init)
        // and should not be called during retry since user is now null
        verifyNever(mockUserState.readUser(uid: null));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when initialization starts', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        bool notified = false;
        appBootstrapState.addListener(() => notified = true);

        // Act
        await appBootstrapState.init();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when initialization completes', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        int notificationCount = 0;
        appBootstrapState.addListener(() => notificationCount++);

        // Act
        await appBootstrapState.init();

        // Assert
        // Should notify at least twice: once for loading, once for ready
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when error occurs', () async {
        // Arrange
        final testError = Exception('Test error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        int notificationCount = 0;
        appBootstrapState.addListener(() => notificationCount++);

        // Act
        await appBootstrapState.init();

        // Assert
        // Should notify at least twice: once for loading, once for error
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when retrying', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        await appBootstrapState.init();

        int notificationCount = 0;
        appBootstrapState.addListener(() => notificationCount++);

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners multiple times during initialization flow', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10));
          return Future.value();
        });
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        final statuses = <AppBootstrapStatus>[];
        appBootstrapState.addListener(() {
          statuses.add(appBootstrapState.status);
        });

        // Act
        await appBootstrapState.init();

        // Assert
        expect(statuses, contains(AppBootstrapStatus.loading));
        expect(statuses, contains(AppBootstrapStatus.ready));
        expect(statuses.length, greaterThanOrEqualTo(2));
      });
    });

    group('AppBootstrapStatus enum', () {
      test('should have all expected values', () {
        expect(
            AppBootstrapStatus.values,
            containsAll([
              AppBootstrapStatus.initial,
              AppBootstrapStatus.loading,
              AppBootstrapStatus.ready,
              AppBootstrapStatus.error,
            ]));
      });

      test('should have exactly 4 values', () {
        expect(AppBootstrapStatus.values.length, 4);
      });
    });

    group('StartupOverlayPolicies', () {
      test('should call all overlay policy methods after successful initialization', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(1);
      });

      test('should call overlay policy methods in correct order', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        final callOrder = <String>[];
        when(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).thenAnswer((_) {
          callOrder.add('hardUpdate');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).thenAnswer((_) {
          callOrder.add('softUpdate');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).thenAnswer((_) {
          callOrder.add('whatsNew');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).thenAnswer((_) {
          callOrder.add('appSurvey');
        });

        // Act
        await appBootstrapState.init();

        // Assert
        expect(callOrder, ['hardUpdate', 'softUpdate', 'whatsNew', 'appSurvey']);
      });

      test('should not call overlay policies if initialization fails', () async {
        // Arrange
        final testError = Exception('Initialization error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.error);
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueHardUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueWhatsNew());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueAppSurvey());
      });

      test('should call overlay policies on each retry', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();
        await appBootstrapState.retry();
        await appBootstrapState.retry();

        // Assert
        // Should be called 3 times (once for init, twice for retries)
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(3);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(3);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(3);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(3);
      });

      test('should call overlay policies after successful retry following error', () async {
        // Arrange
        final testError = Exception('First attempt error');
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenThrow(testError);
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        // First attempt fails
        await appBootstrapState.init();

        // Verify policies not called on error
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueHardUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueWhatsNew());
        verifyNever(mockStartupOverlayPolicies.maybeEnqueueAppSurvey());

        // Now make it succeed
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.retry();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(1);
      });

      test('should call overlay policies with authenticated user', () async {
        // Arrange
        const testUid = 'testUser123';
        when(mockAuthState.currentUserId).thenReturn(testUid);
        when(mockRemoteConfigState.init()).thenAnswer((_) async => Future.value());
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => Future.value());
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => Future.value());
        when(mockSavedListState.readUserSavedLists()).thenAnswer((_) async => Future.value());
        when(mockUserState.loadBlockedUsers()).thenAnswer((_) async => Future.value());

        // Act
        await appBootstrapState.init();

        // Assert
        expect(appBootstrapState.status, AppBootstrapStatus.ready);
        verify(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).called(1);
        verify(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).called(1);
      });

      test('should only call overlay policies after bootstrap status is ready', () async {
        // Arrange
        when(mockAuthState.currentUserId).thenReturn(null);
        when(mockRemoteConfigState.init()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return Future.value();
        });
        when(mockSettingsState.load()).thenAnswer((_) async => Future.value());
        when(mockMunroState.loadMunros()).thenAnswer((_) async => Future.value());

        final callOrder = <String>[];
        appBootstrapState.addListener(() {
          if (appBootstrapState.status == AppBootstrapStatus.ready) {
            callOrder.add('status_ready');
          }
        });

        when(mockStartupOverlayPolicies.maybeEnqueueHardUpdate()).thenAnswer((_) {
          callOrder.add('hardUpdate');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueSoftUpdate()).thenAnswer((_) {
          callOrder.add('softUpdate');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueWhatsNew()).thenAnswer((_) {
          callOrder.add('whatsNew');
        });
        when(mockStartupOverlayPolicies.maybeEnqueueAppSurvey()).thenAnswer((_) {
          callOrder.add('appSurvey');
        });

        // Act
        await appBootstrapState.init();

        // Assert - overlay policies should be called after status is ready
        expect(callOrder.indexOf('status_ready'), lessThan(callOrder.indexOf('hardUpdate')));
        expect(callOrder.indexOf('status_ready'), lessThan(callOrder.indexOf('softUpdate')));
        expect(callOrder.indexOf('status_ready'), lessThan(callOrder.indexOf('whatsNew')));
        expect(callOrder.indexOf('status_ready'), lessThan(callOrder.indexOf('appSurvey')));
      });
    });
  });
}
