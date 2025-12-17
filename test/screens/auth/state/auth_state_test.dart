import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

import 'auth_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AuthRepository,
  UserState,
  User,
  UserCredential,
  AdditionalUserInfo,
  PackageInfo,
  SharedPreferencesService,
  AnalyticsService,
])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserState mockUserState;
  late AuthState authState;

  // Sample data for testing
  final sampleRegistrationData = RegistrationData()
    ..email = 'test@example.com'
    ..password = 'password123'
    ..displayName = 'John Doe'
    ..firstName = 'John'
    ..lastName = 'Doe';

  final sampleUser = AppUser(
    uid: 'user123',
    displayName: 'John Doe',
    firstName: 'John',
    lastName: 'Doe',
    searchName: 'john doe',
    profilePictureURL: 'https://example.com/john.jpg',
    platform: 'iOS',
    appVersion: '1.0.0',
    dateCreated: DateTime.parse('2024-01-01T10:00:00Z'),
    signInMethod: 'email',
    profileVisibility: Privacy.public,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserState = MockUserState();
    authState = AuthState(mockAuthRepository, mockUserState);

    // Mock Platform.isIOS - this is tricky in tests, so we'll work around it
    // By using when() on the methods that depend on it
  });

  group('AuthState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(authState.status, AuthStatus.initial);
        expect(authState.errorMessage, isNull);
      });

      test('currentUserId should delegate to repository', () {
        // Arrange
        when(mockAuthRepository.currentUserId).thenReturn('user123');

        // Act & Assert
        expect(authState.currentUserId, 'user123');
        verify(mockAuthRepository.currentUserId).called(1);
      });

      test('currentUserId should return null when repository returns null', () {
        // Arrange
        when(mockAuthRepository.currentUserId).thenReturn(null);

        // Act & Assert
        expect(authState.currentUserId, isNull);
      });
    });

    group('registerWithEmail', () {
      late MockUser mockFirebaseUser;
      late MockUserCredential mockUserCredential;

      setUp(() {
        mockFirebaseUser = MockUser();
        mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user123');
        when(mockFirebaseUser.displayName).thenReturn('John Doe');
      });

      test('should register user successfully and return AuthResult', () async {
        // Arrange
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert
        expect(authState.status, AuthStatus.authenticated);
        expect(authState.errorMessage, isNull);
        expect(result.success, true);
        
        verify(mockAuthRepository.registerWithEmail(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'John Doe',
        )).called(1);
        
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.uid == 'user123' && 
            user.displayName == 'John Doe' &&
            user.signInMethod == 'email')
        ))).called(1);
      });

      test('should handle error when Firebase user is null', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(null);
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('User not returned from Firebase'));
        expect(result.success, false);
        expect(result.errorMessage, contains('User not returned from Firebase'));
      });

      test('should handle repository error', () async {
        // Arrange
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenThrow(Exception('Registration failed'));

        // Act
        final result = await authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Registration failed'));
        expect(result.success, false);
        expect(result.errorMessage, contains('Exception: Registration failed'));
      });

      test('should set loading status during async operation', () async {
        // Arrange
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return mockUserCredential;
        });
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final future = authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert intermediate state
        expect(authState.status, AuthStatus.loading);
        expect(authState.errorMessage, isNull);

        // Wait for completion
        await future;
        expect(authState.status, AuthStatus.authenticated);
      });
    });

    group('signInWithEmail', () {
      late MockUser mockFirebaseUser;
      late MockUserCredential mockUserCredential;

      setUp(() {
        mockFirebaseUser = MockUser();
        mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user123');
      });

      test('should sign in successfully and return AuthResult', () async {
        // Arrange
        when(mockAuthRepository.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authState.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(authState.status, AuthStatus.authenticated);
        expect(authState.errorMessage, isNull);
        expect(result.success, true);
        
        verify(mockAuthRepository.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should handle sign in error', () async {
        // Arrange
        when(mockAuthRepository.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Invalid credentials'));

        // Act
        final result = await authState.signInWithEmail(
          email: 'test@example.com',
          password: 'wrong_password',
        );

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Invalid credentials'));
        expect(result.success, false);
        expect(result.errorMessage, contains('Exception: Invalid credentials'));
      });

      test('should set loading status during async operation', () async {
        // Arrange
        when(mockAuthRepository.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return mockUserCredential;
        });

        // Act
        final future = authState.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert intermediate state
        expect(authState.status, AuthStatus.loading);

        // Wait for completion
        await future;
        expect(authState.status, AuthStatus.authenticated);
      });
    });

    group('signInWithApple', () {
      late MockUser mockFirebaseUser;
      late MockUserCredential mockUserCredential;
      late MockAdditionalUserInfo mockAdditionalUserInfo;

      setUp(() {
        mockFirebaseUser = MockUser();
        mockUserCredential = MockUserCredential();
        mockAdditionalUserInfo = MockAdditionalUserInfo();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockUserCredential.additionalUserInfo).thenReturn(mockAdditionalUserInfo);
        when(mockFirebaseUser.uid).thenReturn('apple_user_123');
        when(mockAdditionalUserInfo.isNewUser).thenReturn(true);
      });

      test('should sign in with Apple successfully', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple()).thenAnswer((_) async => (
          cred: mockUserCredential,
          givenName: 'John',
          familyName: 'Doe'
        ));
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.signInWithApple();

        // Assert
        expect(authState.status, AuthStatus.authenticated);
        expect(authState.errorMessage, isNull);
        expect(result.success, true);
        
        verify(mockAuthRepository.signInWithApple()).called(1);
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.uid == 'apple_user_123' && 
            user.signInMethod == 'apple sign in' &&
            user.firstName == 'John' &&
            user.lastName == 'Doe')
        ))).called(1);
      });

      test('should handle Apple sign in cancellation', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple()).thenThrow(
          SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.canceled,
            message: 'User canceled',
          ),
        );

        // Act
        final result = await authState.signInWithApple();

        // Assert
        expect(authState.status, AuthStatus.initial);
        expect(result.success, false);
        expect(result.canceled, true);
      });

      test('should handle Apple sign in authorization error', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple()).thenThrow(
          SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.failed,
            message: 'Authorization failed',
          ),
        );

        // Act
        final result = await authState.signInWithApple();

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, 'Authorization failed');
        expect(result.success, false);
        expect(result.errorMessage, 'Authorization failed');
      });

      test('should handle null Firebase user from Apple sign in', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(null);
        when(mockAuthRepository.signInWithApple()).thenAnswer((_) async => (
          cred: mockUserCredential,
          givenName: 'John',
          familyName: 'Doe'
        ));

        // Act
        final result = await authState.signInWithApple();

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('User not returned from Apple sign-in'));
        expect(result.success, false);
      });

      test('should handle empty names from Apple sign in', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple()).thenAnswer((_) async => (
          cred: mockUserCredential,
          givenName: null,
          familyName: null
        ));
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.signInWithApple();

        // Assert
        expect(authState.status, AuthStatus.authenticated);
        expect(result.success, true);
        
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.displayName == 'Apple User' &&
            user.firstName == 'Apple' &&
            user.lastName == 'User')
        ))).called(1);
      });
    });

    group('signInWithGoogle', () {
      late MockUser mockFirebaseUser;
      late MockUserCredential mockUserCredential;

      setUp(() {
        mockFirebaseUser = MockUser();
        mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('google_user_123');
        when(mockFirebaseUser.displayName).thenReturn('Google User');
        when(mockFirebaseUser.photoURL).thenReturn('https://example.com/photo.jpg');
      });

      test('should sign in with Google successfully', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.signInWithGoogle();

        // Assert
        expect(authState.status, AuthStatus.authenticated);
        expect(authState.errorMessage, isNull);
        expect(result.success, true);
        
        verify(mockAuthRepository.signInWithGoogle()).called(1);
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.uid == 'google_user_123' && 
            user.signInMethod == 'google sign in' &&
            user.profilePictureURL == 'https://example.com/photo.jpg')
        ))).called(1);
      });

      test('should handle Google sign in cancellation', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenThrow(
          GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
          ),
        );

        // Act
        final result = await authState.signInWithGoogle();

        // Assert
        expect(authState.status, AuthStatus.initial);
        expect(result.success, false);
        expect(result.canceled, true);
      });

      test('should handle Google sign in error', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenThrow(
          Exception('Google Sign In Error'),
        );

        // Act
        final result = await authState.signInWithGoogle();

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, 'There was an error signing in with Google.');
        expect(result.success, false);
        expect(result.errorMessage, 'There was an error signing in with Google.');
      });

      test('should handle null Firebase user from Google sign in', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(null);
        when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authState.signInWithGoogle();

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('User not returned from Google sign-in'));
        expect(result.success, false);
      });

      test('should parse Google user names correctly', () async {
        // Arrange
        when(mockFirebaseUser.displayName).thenReturn('John Michael Doe');
        when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        await authState.signInWithGoogle();

        // Assert
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.firstName == 'John' &&
            user.lastName == 'Michael Doe')
        ))).called(1);
      });
    });

    group('forgotPassword', () {
      test('should send password reset email successfully', () async {
        // Arrange
        when(mockAuthRepository.sendPasswordResetEmail(anyNamed('email')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.forgotPassword(email: 'test@example.com');

        // Assert
        expect(authState.status, AuthStatus.initial);
        expect(result.success, true);
        
        verify(mockAuthRepository.sendPasswordResetEmail('test@example.com')).called(1);
      });

      test('should handle password reset error', () async {
        // Arrange
        when(mockAuthRepository.sendPasswordResetEmail(anyNamed('email')))
            .thenThrow(Exception('Email not found'));

        // Act
        final result = await authState.forgotPassword(email: 'nonexistent@example.com');

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Email not found'));
        expect(result.success, false);
        expect(result.errorMessage, contains('Exception: Email not found'));
      });

      test('should set loading status during async operation', () async {
        // Arrange
        when(mockAuthRepository.sendPasswordResetEmail(anyNamed('email')))
            .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        // Act
        final future = authState.forgotPassword(email: 'test@example.com');

        // Assert intermediate state
        expect(authState.status, AuthStatus.loading);

        // Wait for completion
        await future;
        expect(authState.status, AuthStatus.initial);
      });
    });

    group('signOut', () {
      test('should sign out successfully and reset user state', () async {
        // Arrange
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});
        when(mockUserState.reset()).thenReturn(null);

        // Act
        final result = await authState.signOut();

        // Assert
        expect(authState.status, AuthStatus.initial);
        expect(result.success, true);
        
        verify(mockAuthRepository.signOut()).called(1);
        verify(mockUserState.reset()).called(1);
      });

      test('should handle sign out error', () async {
        // Arrange
        when(mockAuthRepository.signOut()).thenThrow(Exception('Sign out failed'));

        // Act
        final result = await authState.signOut();

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Sign out failed'));
        expect(result.success, false);
      });

      test('should set loading status during async operation', () async {
        // Arrange
        when(mockAuthRepository.signOut()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockUserState.reset()).thenReturn(null);

        // Act
        final future = authState.signOut();

        // Assert intermediate state
        expect(authState.status, AuthStatus.loading);

        // Wait for completion
        await future;
        expect(authState.status, AuthStatus.initial);
      });
    });

    group('deleteUser', () {
      test('should delete user successfully', () async {
        // Arrange
        when(mockUserState.deleteUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});
        when(mockAuthRepository.deleteAuthUser()).thenAnswer((_) async {});

        // Act
        final result = await authState.deleteUser(sampleUser);

        // Assert
        expect(authState.status, AuthStatus.initial);
        expect(result.success, true);
        
        verify(mockUserState.deleteUser(appUser: sampleUser)).called(1);
        verify(mockAuthRepository.deleteAuthUser()).called(1);
      });

      test('should handle user deletion error', () async {
        // Arrange
        when(mockUserState.deleteUser(appUser: anyNamed('appUser')))
            .thenThrow(Exception('Delete failed'));

        // Act
        final result = await authState.deleteUser(sampleUser);

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Delete failed'));
        expect(result.success, false);
      });

      test('should handle auth user deletion error', () async {
        // Arrange
        when(mockUserState.deleteUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});
        when(mockAuthRepository.deleteAuthUser()).thenThrow(Exception('Auth delete failed'));

        // Act
        final result = await authState.deleteUser(sampleUser);

        // Assert
        expect(authState.status, AuthStatus.error);
        expect(authState.errorMessage, contains('Exception: Auth delete failed'));
        expect(result.success, false);
      });

      test('should set loading status during async operation', () async {
        // Arrange
        when(mockUserState.deleteUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockAuthRepository.deleteAuthUser()).thenAnswer((_) async {});

        // Act
        final future = authState.deleteUser(sampleUser);

        // Assert intermediate state
        expect(authState.status, AuthStatus.loading);

        // Wait for completion
        await future;
        expect(authState.status, AuthStatus.initial);
      });
    });

    group('Private Helper Methods', () {
      test('_setLoading should update status and clear error', () {
        // Arrange
        authState.status; // Initialize to initial
        bool notified = false;
        authState.addListener(() => notified = true);

        // Act - we can't directly test private methods, but we can test their effects
        // through public methods that use them
        authState.signInWithEmail(email: 'test@example.com', password: 'password');

        // Assert - the loading state should be set immediately
        expect(authState.status, AuthStatus.loading);
        expect(authState.errorMessage, isNull);
        expect(notified, true);
      });
    });

    group('Edge Cases', () {
      test('should handle Firebase user with null display name', () async {
        // Arrange
        final mockFirebaseUser = MockUser();
        final mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user123');
        when(mockFirebaseUser.displayName).thenReturn(null);
        
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert
        expect(result.success, true);
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => user.displayName == 'New User')
        ))).called(1);
      });

      test('should handle Google user with single name', () async {
        // Arrange
        final mockFirebaseUser = MockUser();
        final mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('google_user_123');
        when(mockFirebaseUser.displayName).thenReturn('SingleName');
        
        when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        await authState.signInWithGoogle();

        // Assert
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.firstName == 'SingleName' &&
            user.lastName == '')
        ))).called(1);
      });

      test('should handle registration data with null values', () async {
        // Arrange
        final emptyRegistrationData = RegistrationData()
          ..email = 'test@example.com'
          ..password = 'password123';
        
        final mockFirebaseUser = MockUser();
        final mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user123');
        when(mockFirebaseUser.displayName).thenReturn('Default Name');
        
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});

        // Act
        final result = await authState.registerWithEmail(
          registrationData: emptyRegistrationData,
        );

        // Assert
        expect(result.success, true);
        verify(mockUserState.createUser(appUser: argThat(
          predicate<AppUser>((user) => 
            user.firstName == null &&
            user.lastName == null)
        ))).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when status changes', () async {
        // Arrange
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});
        when(mockUserState.reset()).thenReturn(null);
        
        int notificationCount = 0;
        authState.addListener(() => notificationCount++);

        // Act
        await authState.signOut();

        // Assert - Should notify twice: once for loading, once for completion
        expect(notificationCount, 2);
      });

      test('should notify listeners when error occurs', () async {
        // Arrange
        when(mockAuthRepository.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Sign in failed'));
        
        int notificationCount = 0;
        authState.addListener(() => notificationCount++);

        // Act
        await authState.signInWithEmail(
          email: 'test@example.com',
          password: 'wrong_password',
        );

        // Assert - Should notify twice: once for loading, once for error
        expect(notificationCount, 2);
      });

      test('should notify listeners for each state change in successful operation', () async {
        // Arrange
        final mockFirebaseUser = MockUser();
        final mockUserCredential = MockUserCredential();
        
        when(mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user123');
        when(mockFirebaseUser.displayName).thenReturn('John Doe');
        
        when(mockAuthRepository.registerWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserState.createUser(appUser: anyNamed('appUser')))
            .thenAnswer((_) async {});
        
        int notificationCount = 0;
        authState.addListener(() => notificationCount++);

        // Act
        await authState.registerWithEmail(
          registrationData: sampleRegistrationData,
        );

        // Assert - Should notify twice: once for loading, once for authenticated
        expect(notificationCount, 2);
      });
    });
  });

  group('AuthResult', () {
    test('should create AuthResult with success true', () {
      final result = AuthResult(success: true);
      
      expect(result.success, true);
      expect(result.showOnboarding, false);
      expect(result.canceled, false);
      expect(result.errorMessage, isNull);
    });

    test('should create AuthResult with all parameters', () {
      final result = AuthResult(
        success: false,
        showOnboarding: true,
        canceled: true,
        errorMessage: 'Test error',
      );
      
      expect(result.success, false);
      expect(result.showOnboarding, true);
      expect(result.canceled, true);
      expect(result.errorMessage, 'Test error');
    });
  });
}