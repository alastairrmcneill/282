import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._auth, this._googleSignIn);

  Stream<String?> get authIdChanges => _auth.authStateChanges().map((user) => user?.uid);

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

  Future<UserCredential> signInWithGoogle() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        "Platform doesn't support authenticate(). Use platform-specific sign-in method.",
      );
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    await cred.user?.getIdToken(true);

    return cred;
  }
}
