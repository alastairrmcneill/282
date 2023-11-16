// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:two_eight_two/repos/repos.dart';

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
      await UserDatabase.create(context, appUser: appUser);

      stopCircularProgressOverlay(context);
      // Navigate to the right place
      Navigator.pushReplacementNamed(context, navigationState.navigateToRoute);
    } on FirebaseAuthException catch (error) {
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.code);
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
      await UserDatabase.readCurrentUser(context);

      // Save to a provider

      stopCircularProgressOverlay(context);

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, navigationState.navigateToRoute);
      // Navigator.pushNamedAndRemoveUntil(context, newRouteName, (route) => false)
    } on FirebaseAuthException catch (error) {
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.code);
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
    } on FirebaseAuthException catch (error) {
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.code);
    }
  }

  static Future signOut(BuildContext context) async {
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    startCircularProgressOverlay(context);

    try {
      await _auth.signOut();
      stopCircularProgressOverlay(context);

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, "/home_screen");
    } on FirebaseAuthException catch (error) {
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: error.code);
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

      AppUser appUser = AppUser(
        uid: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName,
        searchName: _auth.currentUser!.displayName?.toLowerCase(),
      );
      await UserDatabase.create(context, appUser: appUser);

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, navigationState.navigateToRoute);
    } on FirebaseAuthException catch (error) {
      showErrorDialog(context, message: error.code);
    } on SignInWithAppleAuthorizationException catch (error) {
      showErrorDialog(context, message: error.message);
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

      AppUser appUser = AppUser(
        uid: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName,
        searchName: _auth.currentUser!.displayName?.toLowerCase(),
      );
      await UserDatabase.create(context, appUser: appUser);

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, navigationState.navigateToRoute);
    } on FirebaseAuthException catch (error) {
      showErrorDialog(context, message: error.code);
    }
  }

  static Future updateAuthUser(BuildContext context, {required AppUser appUser}) async {
    // Update auth user details
    if (_auth.currentUser == null) return;

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
  }

  static Future deleteUserFromUid(BuildContext context, {required String uid}) async {
    try {
      UserState userState = Provider.of<UserState>(context, listen: false);

      userState.setCurrentUser = null;
      await UserDatabase.deleteUserWithUID(context, uid: _auth.currentUser!.uid);
      await _auth.currentUser?.delete();

      // Navigate to the right place
      Navigator.pushReplacementNamed(context, "/home_screen");
    } on FirebaseAuthException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error deleting your account");
    }
  }
}
