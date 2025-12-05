// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isGoogleSignInInitialized = false;

  static Stream<AppUser?> get appUserStream {
    return _auth.authStateChanges().map((User? user) => user != null ? AppUser.appUserFromFirebaseUser(user) : null);
  }

  static Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    }
  }

  // Current user id
  static String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  static Future registerWithEmail(BuildContext context, {required RegistrationData registrationData}) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    final userState = context.read<UserState>();
    startCircularProgressOverlay(context);
    try {
      // Setup auth user
      await _auth.createUserWithEmailAndPassword(email: registrationData.email!, password: registrationData.password!);

      // Update details
      await _auth.currentUser!.updateDisplayName(registrationData.displayName).whenComplete(
        () async {
          await _auth.currentUser!.reload();
        },
      );

      await _auth.currentUser!.getIdToken();

      bool isIOS = Platform.isIOS;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;

      // Save to user database
      AppUser appUser = AppUser(
        uid: _auth.currentUser?.uid,
        displayName: _auth.currentUser?.displayName ?? "New User",
        searchName: _auth.currentUser?.displayName?.toLowerCase() ?? "new user",
        firstName: registrationData.firstName,
        lastName: registrationData.lastName,
        signInMethod: "email",
        platform: isIOS ? "iOS" : "Android",
        appVersion: appVersion,
        dateCreated: DateTime.now(),
        profileVisibility: Privacy.public,
      );

      await userState.createUser(appUser: appUser);

      AnalyticsService.logSignUp(method: "email", platform: isIOS ? "iOS" : "Android");

      stopCircularProgressOverlay(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);

      // Navigate to the right place
      await _afterSignInNavigation(context);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.code);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future signInWithEmail(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    UserState userState = context.read<UserState>();
    startCircularProgressOverlay(context);

    try {
      // Sign into auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (_auth.currentUser == null) return;

      await _auth.currentUser!.getIdToken(true);

      // Fetch database detail
      await userState.readCurrentUser();

      // Save to a provider

      stopCircularProgressOverlay(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);

      // Navigate to the right place
      await _afterSignInNavigation(context);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error signing in.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future forgotPassword(
    BuildContext context, {
    required String email,
  }) async {
    startCircularProgressOverlay(context);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      stopCircularProgressOverlay(context);
      showSnackBar(context, 'Sent password reset email.');
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error retreiving password. Please try again.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future signOut(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    UserState userState = context.read<UserState>();
    startCircularProgressOverlay(context);

    try {
      stopCircularProgressOverlay(context);

      // Remove FCM Token
      AppUser? appUser = userState.currentUser;
      if (appUser != null) {
        AppUser newAppUser = appUser.copyWith(fcmToken: "");
        userState.updateUser(appUser: newAppUser);
      }

      resetAppData(context);

      await _auth.signOut();
      // Navigate to the right place
      Navigator.pushReplacementNamed(context, HomeScreen.route);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error signing out. Please try again.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future signInWithApple(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    UserState userState = context.read<UserState>();

    try {
      startCircularProgressOverlay(context);
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.fullName,
          AppleIDAuthorizationScopes.email,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      OAuthCredential appleCredential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      UserCredential credential = await _auth.signInWithCredential(appleCredential);

      // Handle name information carefully
      String displayName = "";
      String firstName = "";
      String lastName = "";

      // First check if Apple provided name information (only available on first sign-in)
      if (appleIdCredential.givenName != null || appleIdCredential.familyName != null) {
        firstName = appleIdCredential.givenName ?? "";
        lastName = appleIdCredential.familyName ?? "";
        displayName = "$firstName $lastName".trim();

        // Update Firebase user's display name if we got name info from Apple
        if (displayName.isNotEmpty && (credential.user?.displayName == null || credential.user!.displayName!.isEmpty)) {
          await credential.user?.updateDisplayName(displayName).whenComplete(
            () async {
              await credential.user?.reload();
            },
          );
        }
      }

      // If no name from Apple, try existing Firebase user display name
      if (displayName.isEmpty) {
        displayName = _auth.currentUser?.displayName ?? "";
        if (displayName.isNotEmpty) {
          // Parse existing display name into first/last names
          List<String> names = displayName.split(" ");
          if (names.length > 1) {
            firstName = names[0];
            lastName = names.sublist(1).join(" ");
          } else if (names.length == 1) {
            firstName = names[0];
          }
        }
      }

      // Final fallback - use a generic name if still empty
      if (displayName.isEmpty) {
        displayName = "Apple User";
        firstName = "Apple";
        lastName = "User";
      }

      await _auth.currentUser?.getIdToken(true);

      bool isIOS = Platform.isIOS;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;

      // Check if this is a new user or returning user
      bool isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

      // TODO: if this is a new user then only create user record otherwise skip over? Test this
      AppUser appUser = AppUser(
        uid: _auth.currentUser?.uid,
        displayName: displayName,
        searchName: displayName.toLowerCase(),
        firstName: firstName,
        lastName: lastName,
        platform: isIOS ? "iOS" : "Android",
        appVersion: appVersion,
        dateCreated: DateTime.now(),
        signInMethod: "apple sign in",
        profileVisibility: Privacy.public,
      );

      await userState.createUser(appUser: appUser);

      // Only log as sign-up if it's actually a new user
      if (isNewUser) {
        AnalyticsService.logSignUp(method: "apple", platform: isIOS ? "iOS" : "Android");
      }

      stopCircularProgressOverlay(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);

      // Navigate to the right place
      await _afterSignInNavigation(context);
    } on SignInWithAppleAuthorizationException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      // Don't show error if user canceled
      if (error.code != AuthorizationErrorCode.canceled) {
        showErrorDialog(context, message: error.message);
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error signing in.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future signInWithGoogle(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    UserState userState = context.read<UserState>();

    startCircularProgressOverlay(context);

    try {
      // Initialize Google Sign In if not already done
      await _initializeGoogleSignIn();

      // Check if we can use authenticate() or need platform-specific approach
      GoogleSignInAccount? googleUser;
      if (_googleSignIn.supportsAuthenticate()) {
        googleUser = await _googleSignIn.authenticate();
      } else {
        // Fallback for platforms that don't support authenticate()
        // This would typically be web, which requires special handling
        throw Exception("Platform doesn't support authenticate(). Use platform-specific sign-in method.");
      }

      // Obtain the auth details from the request
      // Note: In 7.x, authentication property is accessed directly from the user
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential - in 7.x, only idToken is available
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, get the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      await _auth.currentUser?.getIdToken(true);

      List<String> names = googleUser.displayName?.split(" ") ?? [];
      String firstName = "";
      String lastName = "";
      if (names.length > 1) {
        firstName = names[0];
        lastName = names.sublist(1).join(" ");
      } else if (names.length == 1) {
        firstName = names[0];
      }

      bool isIOS = Platform.isIOS;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;

      AppUser appUser = AppUser(
        uid: _auth.currentUser?.uid ?? "",
        displayName: _auth.currentUser?.displayName ?? "New User",
        firstName: firstName,
        lastName: lastName,
        searchName: _auth.currentUser?.displayName?.toLowerCase() ?? "new user",
        profilePictureURL: _auth.currentUser?.photoURL,
        platform: isIOS ? "iOS" : "Android",
        appVersion: appVersion,
        dateCreated: DateTime.now(),
        signInMethod: "google sign in",
        profileVisibility: Privacy.public,
      );

      await userState.createUser(appUser: appUser);

      AnalyticsService.logSignUp(method: "google", platform: isIOS ? "iOS" : "Android");

      stopCircularProgressOverlay(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);

      // Navigate to the right place
      await _afterSignInNavigation(context);
    } on GoogleSignInException catch (error, stackTrace) {
      Log.error("Google Sign In Error: ${error.toString()}", stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      if (error.code != GoogleSignInExceptionCode.canceled) {
        showErrorDialog(context, message: "There was an error signing in with Google.");
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error signing in.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future updateAuthUser(BuildContext context, {required AppUser appUser}) async {
    // Update auth user details
    if (_auth.currentUser == null) return;

    try {
      await _auth.currentUser!.updateDisplayName(appUser.displayName).whenComplete(
        () async {
          await _auth.currentUser!.reload();
        },
      );

      await _auth.currentUser!.updatePhotoURL(appUser.profilePictureURL).whenComplete(
        () async {
          await _auth.currentUser!.reload();
        },
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error updating your profile.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future deleteUser(BuildContext context, {required AppUser appUser}) async {
    UserState userState = context.read<UserState>();

    try {
      await userState.deleteUser(appUser: appUser);
      await _auth.currentUser?.delete();

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, HomeScreen.route);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your account. Please try again.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.toString());
    }
  }

  static resetAppData(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    userState.reset();

    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    profileState.reset();

    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    followersState.reset();

    LikesState likesState = Provider.of<LikesState>(context, listen: false);
    likesState.reset();

    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);
    commentsState.reset();

    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);
    munroCompletionState.reset();
  }

  static Future _afterSignInNavigation(BuildContext context) async {
    bool showInAppOnboarding = await SharedPreferencesService.getShowInAppOnboarding();

    if (showInAppOnboarding) {
      UserState userState = context.read<UserState>();
      await userState.readCurrentUser();

      BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);
      MunroState munroState = Provider.of<MunroState>(context, listen: false);
      AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
      MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

      await munroCompletionState.loadUserMunroCompletions();

      bulkMunroUpdateState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;
      munroState.setFilterString = "";

      Achievement? munroChallenge = await context
          .read<UserAchievementsRepository>()
          .getLatestMunroChallengeAchievement(userId: userState.currentUser!.uid ?? "");

      achievementsState.reset();
      achievementsState.setCurrentAchievement = munroChallenge;

      Navigator.of(context).pushNamedAndRemoveUntil(
        InAppOnboarding.route,
        (Route<dynamic> route) => false,
      );
    }
  }
}
