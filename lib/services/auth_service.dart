// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Stream<AppUser?> get appUserStream {
    return _auth.authStateChanges().map((User? user) => user != null ? AppUser.appUserFromFirebaseUser(user) : null);
  }

  // Current user id
  static String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  static Future registerWithEmail(BuildContext context, {required RegistrationData registrationData}) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
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

      if (_auth.currentUser == null) return;

      // Save to user database
      AppUser appUser = AppUser(
        uid: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName,
        searchName: _auth.currentUser!.displayName?.toLowerCase(),
        firstName: registrationData.firstName,
        lastName: registrationData.lastName,
      );
      await UserService.createUser(context, appUser: appUser);

      stopCircularProgressOverlay(context);

      // Navigate to the right place
      await _afterSignInNavigation(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);
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
    startCircularProgressOverlay(context);

    try {
      // Sign into auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (_auth.currentUser == null) return;

      // Fetch database detail
      await UserService.readCurrentUser(context);

      // Save to a provider

      stopCircularProgressOverlay(context);

      // Navigate to the right screen
      await _afterSignInNavigation(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);
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
    UserState userState = Provider.of<UserState>(context, listen: false);
    startCircularProgressOverlay(context);

    try {
      await _auth.signOut();
      stopCircularProgressOverlay(context);

      // Remove FCM Token
      AppUser? appUser = userState.currentUser;
      if (appUser != null) {
        AppUser newAppUser = appUser.copyWith(fcmToken: null);
        UserService.updateUser(context, appUser: newAppUser);
      }

      await resetAppData(context);
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
    try {
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

      if (credential.user!.displayName == null) {
        await credential.user!
            .updateDisplayName(
          "${appleIdCredential.givenName ?? ""} ${appleIdCredential.familyName ?? ""}",
        )
            .whenComplete(
          () async {
            await credential.user!.reload();
          },
        );
      }

      if (credential.user!.email == null) {
        await credential.user!.updateEmail(appleIdCredential.email!).whenComplete(
          () async {
            await credential.user!.reload();
          },
        );
      }

      if (_auth.currentUser == null) return;

      List<String> names = _auth.currentUser!.displayName?.split(" ") ?? [];
      String firstName = "";
      String lastName = "";
      if (names.length > 1) {
        firstName = names[0];
        lastName = names.sublist(1).join(" ");
      } else if (names.length == 1) {
        firstName = names[0];
      }

      AppUser appUser = AppUser(
        uid: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName,
        searchName: _auth.currentUser!.displayName?.toLowerCase(),
      );
      await UserService.createUser(context, appUser: appUser);

      // Navigate to the right place
      await _afterSignInNavigation(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);
    } on SignInWithAppleAuthorizationException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error signing in.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
    }
  }

  static Future signInWithGoogle(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential credential = await _auth.signInWithCredential(googleCredential);

      if (_auth.currentUser == null) return;

      List<String> names = googleUser.displayName?.split(" ") ?? [];
      String firstName = "";
      String lastName = "";
      if (names.length > 1) {
        firstName = names[0];
        lastName = names.sublist(1).join(" ");
      } else if (names.length == 1) {
        firstName = names[0];
      }

      AppUser appUser = AppUser(
        uid: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName,
        firstName: firstName,
        lastName: lastName,
        searchName: _auth.currentUser!.displayName?.toLowerCase(),
        profilePictureURL: _auth.currentUser!.photoURL,
      );

      await UserService.createUser(context, appUser: appUser);

      // Navigate to the right place
      await _afterSignInNavigation(context);

      // Check for push notifications
      await PushNotificationService.initNotifications(context);
    } on FirebaseAuthException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error signing in.");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
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
    try {
      await _auth.currentUser?.delete();
      await UserService.deleteUser(context, appUser: appUser);

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

  static Future resetAppData(BuildContext context) async {
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

    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    munroState.reset();
    await MunroService.loadMunroData(context);
  }

  static Future _afterSignInNavigation(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    switch (navigationState.navigateToRoute) {
      case HomeScreen.route:
        await MunroService.loadPersonalMunroData(context);
        break;
      case HomeScreen.feedTabRoute:
        await PostService.getFeed(context);
        NotificationsService.getUserNotifications(context);
        break;
      case HomeScreen.savedTabRoute:
        await MunroService.loadPersonalMunroData(context);
        break;
      case HomeScreen.profileTabRoute:
        await UserService.readCurrentUser(context);
        await ProfileService.loadUserFromUid(context, userId: _auth.currentUser!.uid);
        break;
      case MunroScreen.route:
        break;
      default:
    }

    // Navigate to the right place
    Navigator.pushNamedAndRemoveUntil(
      context,
      navigationState.navigateToRoute, // The name of the route you want to navigate to
      (Route<dynamic> route) => false, // This predicate ensures all routes are removed
    );
  }
}
