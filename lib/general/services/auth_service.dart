import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/features/home/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Stream<AppUser?> get appUserStream {
    return _auth
        .authStateChanges()
        .map((User? user) => user != null ? AppUser.appUserFromFirebaseUser(user) : null);
  }

  static Future registerWithEmail(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
  }) async {
    // Setup auth user
    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    // Update details
    await _auth.currentUser!.updateDisplayName(name).whenComplete(
      () async {
        await _auth.currentUser!.reload();
      },
    );

    // Save to user database

    // Navigate to right place
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => HomeScreen()), (_) => false);
  }

  static Future signInWithEmail(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    // Sign into auth
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    // Fetch database detail

    // Save to a provider

    // Navigate to the right place
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => HomeScreen()), (_) => false);
  }

  static Future forgotPassword(
    BuildContext context, {
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
    // Show a success message when it works
  }

  static Future signOut(BuildContext context) async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => HomeScreen()), (_) => false);
  }

  static signInWithApple(BuildContext context) async {
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

      // AppUser appUser = AppUser(
      //   uid: _auth.currentUser!.uid,
      //   name: _auth.currentUser!.displayName!,
      // );
      // await UserDatabase.create(context, appUser: appUser);
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => HomeScreen()), (_) => false);
    } on FirebaseAuthException catch (error) {
      showErrorDialog(context,
          message: error.message ?? "There was an error with Apple sign in.");
    } on SignInWithAppleAuthorizationException catch (error) {
      showErrorDialog(context, message: error.message);
    }
  }

  static signInWithGoogle(BuildContext context) async {
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

      // AppUser appUser = AppUser(
      //   uid: _auth.currentUser!.uid,
      //   name: _auth.currentUser!.displayName!,
      // );
      // await UserDatabase.create(context, appUser: appUser);
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => HomeScreen()), (_) => false);
    } on FirebaseAuthException catch (error) {
      showErrorDialog(context,
          message: error.message ?? 'There was an error with Google sign in.');
    }
  }
}
