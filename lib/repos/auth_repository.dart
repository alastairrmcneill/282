import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/models/models.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._auth, this._googleSignIn);

  Stream<AppUser?> get appUserStream =>
      _auth.authStateChanges().map((user) => user != null ? AppUser.appUserFromFirebaseUser(user) : null);

  String? get currentUserId => _auth.currentUser?.uid;
  User? get firebaseUser => _auth.currentUser;

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    if (displayName != null && displayName.isNotEmpty) {
      await cred.user?.updateDisplayName(displayName).then((_) async {
        await cred.user?.reload();
      });
    }

    await cred.user?.getIdToken(true);
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.getIdToken(true);
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  //   Future<void> updateAuthUser({
  //   String? displayName,
  //   String? photoUrl,
  // }) async {
  //   final user = _auth.currentUser;
  //   if (user == null) return;

  //   if (displayName != null) {
  //     await user.updateDisplayName(displayName);
  //   }
  //   if (photoUrl != null) {
  //     await user.updatePhotoURL(photoUrl);
  //   }
  //   await user.reload();
  // }

  Future<void> deleteAuthUser() async {
    await _auth.currentUser?.delete();
  }

  // ---- Apple Sign In ----

  Future<({UserCredential cred, String? givenName, String? familyName})> signInWithApple() async {
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.fullName,
        AppleIDAuthorizationScopes.email,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final appleCredential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    final cred = await _auth.signInWithCredential(appleCredential);
    await cred.user?.getIdToken(true);

    return (
      cred: cred,
      givenName: appleIdCredential.givenName,
      familyName: appleIdCredential.familyName,
    );
  }

  // ---- Google Sign In ----

  bool get supportsGoogleAuthenticate => _googleSignIn.supportsAuthenticate();

  Future<UserCredential> signInWithGoogle() async {
    //TODO fix for android
    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        "Platform doesn't support authenticate(). Use platform-specific sign-in method.",
      );
    }
    GoogleSignInAccount? googleUser;

    if (supportsGoogleAuthenticate) {
      googleUser = await _googleSignIn.authenticate();
    } else {
      // Fallback for platforms that don't support authenticate()
      // This would typically be web, which requires special handling
      throw Exception("Platform doesn't support authenticate(). Use platform-specific sign-in method.");
    }

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    await cred.user?.getIdToken(true);

    return cred;
  }
}
