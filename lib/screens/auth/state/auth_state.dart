import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository _authRepo;
  final UserState _userState;
  final AppFlagsRepository _appFlagsRepository;
  final Analytics _analytics;
  final Logger _logger;

  AuthState(
    this._authRepo,
    this._userState,
    this._appFlagsRepository,
    this._analytics,
    this._logger,
  );

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  String? get currentUserId => _authRepo.currentUserId;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setAuthenticated() {
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  Future<AuthResult> registerWithEmail({
    required RegistrationData registrationData,
  }) async {
    _setLoading();

    try {
      final cred = await _authRepo.registerWithEmail(
        email: registrationData.email!,
        password: registrationData.password!,
        displayName: registrationData.displayName,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw Exception("User not returned from Firebase.");
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final isIOS = Platform.isIOS;

      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? "New User",
        searchName: (firebaseUser.displayName ?? "new user").toLowerCase(),
        firstName: registrationData.firstName,
        lastName: registrationData.lastName,
        signInMethod: "email",
        platform: isIOS ? "iOS" : "Android",
        appVersion: packageInfo.version,
        dateCreated: DateTime.now(),
        profileVisibility: Privacy.public,
      );

      await _userState.createUser(appUser: appUser);

      await _analytics.identify(firebaseUser.uid);
      _logger.identify(firebaseUser.uid);

      _analytics.track(AnalyticsEvent.signUp, props: {
        AnalyticsProp.method: 'email',
        AnalyticsProp.platform: isIOS ? 'iOS' : 'Android',
      });

      _setAuthenticated();

      // State doesn’t navigate – just tell UI what to do.
      final showOnboarding = _appFlagsRepository.showInAppOnboarding;

      return AuthResult(success: true, showOnboarding: showOnboarding);
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      await _authRepo.signInWithEmail(email: email, password: password);

      _setAuthenticated();

      final showOnboarding = _appFlagsRepository.showInAppOnboarding;

      return AuthResult(success: true, showOnboarding: showOnboarding);
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signInWithApple() async {
    _setLoading();
    try {
      final result = await _authRepo.signInWithApple();
      final cred = result.cred;
      final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
      final firebaseUser = cred.user;

      if (firebaseUser == null) {
        throw Exception("User not returned from Apple sign-in.");
      }

      String displayName = "${result.givenName ?? ""} ${result.familyName ?? ""}".trim();
      String firstName = result.givenName ?? "";
      String lastName = result.familyName ?? "";

      // build names based on rules from your old code
      if (displayName.isEmpty) {
        final names = displayName.split(" ");
        if (names.length > 1) {
          firstName = names[0];
          lastName = names.sublist(1).join(" ");
        } else if (names.length == 1) {
          firstName = names[0];
        }
      }

      if (displayName.isEmpty) {
        displayName = "Apple User";
        firstName = "Apple";
        lastName = "User";
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final isIOS = Platform.isIOS;

      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: displayName,
        searchName: displayName.toLowerCase(),
        firstName: firstName,
        lastName: lastName,
        platform: isIOS ? "iOS" : "Android",
        appVersion: packageInfo.version,
        dateCreated: DateTime.now(),
        signInMethod: "apple sign in",
        profileVisibility: Privacy.public,
      );

      await _userState.createUser(appUser: appUser);

      await _analytics.identify(firebaseUser.uid);
      _logger.identify(firebaseUser.uid);

      if (isNewUser) {
        _analytics.track(AnalyticsEvent.signUp, props: {
          AnalyticsProp.method: 'apple',
          AnalyticsProp.platform: isIOS ? 'iOS' : 'Android',
        });
      }

      _setAuthenticated();

      final showOnboarding = _appFlagsRepository.showInAppOnboarding;

      return AuthResult(success: true, showOnboarding: showOnboarding);
    } on SignInWithAppleAuthorizationException catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);

      if (e.code == AuthorizationErrorCode.canceled) {
        _status = AuthStatus.initial;
        notifyListeners();
        return AuthResult(success: false, canceled: true);
      }

      _setError(e.message);
      return AuthResult(
        success: false,
        errorMessage: e.message,
      );
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    _setLoading();
    try {
      final cred = await _authRepo.signInWithGoogle();
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw Exception("User not returned from Google sign-in.");
      }

      final googleDisplayName = firebaseUser.displayName ?? "";
      final names = googleDisplayName.split(" ");
      String firstName = "";
      String lastName = "";
      if (names.length > 1) {
        firstName = names[0];
        lastName = names.sublist(1).join(" ");
      } else if (names.length == 1) {
        firstName = names[0];
      }

      final isIOS = Platform.isIOS;
      final packageInfo = await PackageInfo.fromPlatform();

      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? "New User",
        firstName: firstName,
        lastName: lastName,
        searchName: (firebaseUser.displayName ?? "new user").toLowerCase(),
        profilePictureURL: firebaseUser.photoURL,
        platform: isIOS ? "iOS" : "Android",
        appVersion: packageInfo.version,
        dateCreated: DateTime.now(),
        signInMethod: "google sign in",
        profileVisibility: Privacy.public,
      );

      await _userState.createUser(appUser: appUser);

      await _analytics.identify(firebaseUser.uid);
      _logger.identify(firebaseUser.uid);

      _analytics.track(AnalyticsEvent.signUp, props: {
        AnalyticsProp.method: 'google',
        AnalyticsProp.platform: isIOS ? 'iOS' : 'Android',
      });

      _setAuthenticated();

      final showOnboarding = _appFlagsRepository.showInAppOnboarding;

      return AuthResult(success: true, showOnboarding: showOnboarding);
    } on GoogleSignInException catch (e, st) {
      _logger.error("Google Sign In Error: $e", stackTrace: st);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _status = AuthStatus.initial;
        notifyListeners();
        return AuthResult(success: false, canceled: true);
      }

      _setError("There was an error signing in with Google.");
      return AuthResult(
        success: false,
        errorMessage: "There was an error signing in with Google.",
      );
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    _setLoading();
    try {
      await _authRepo.sendPasswordResetEmail(email);
      _status = AuthStatus.initial;
      notifyListeners();
      return AuthResult(success: true);
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signOut() async {
    _setLoading();
    try {
      _analytics.reset();
      _logger.clearUser();
      await _authRepo.signOut();
      _userState.reset();

      _status = AuthStatus.initial;
      notifyListeners();
      return AuthResult(success: true);
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> deleteUser(AppUser appUser) async {
    _setLoading();
    try {
      _analytics.reset();
      _logger.clearUser();
      await _userState.deleteUser(appUser: appUser);
      await _authRepo.deleteAuthUser();
      _status = AuthStatus.initial;
      notifyListeners();
      return AuthResult(success: true);
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _setError(e.toString());
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }
}

enum AuthStatus { initial, loading, authenticated, error }

class AuthResult {
  final bool success;
  final bool showOnboarding;
  final bool canceled;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.showOnboarding = false,
    this.canceled = false,
    this.errorMessage,
  });
}
