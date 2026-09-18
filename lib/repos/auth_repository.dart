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
    final wasAnnonymous = _auth.currentUser?.isAnonymous ?? false;

    final cred = wasAnnonymous
        ? await _auth.currentUser?.linkWithCredential(EmailAuthProvider.credential(email: email, password: password))
        : await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null && displayName.isNotEmpty) {
      await cred?.user?.updateDisplayName(displayName).then((_) async {
        await cred.user?.reload();
      });
    }

    await cred?.user?.getIdToken(true);
    return cred!;
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

  Future<({OAuthCredential credential, String? givenName, String? familyName})> getAppleCredential() async {
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

    return (
      credential: appleCredential,
      givenName: appleIdCredential.givenName,
      familyName: appleIdCredential.familyName,
    );
  }

  // ---- Google Sign In ----

  Future<OAuthCredential> getGoogleCredential() async {
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

    return credential;
  }

  // Annonymous Sign In
  Future<UserCredential> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    await _waitForAuthenticatedClaim(cred.user);
    return cred;
  }

  Future<UserCredential> signInWithCredential(OAuthCredential credential) async {
    final cred = await _auth.signInWithCredential(credential);
    await cred.user?.getIdToken(true);
    return cred;
  }

  Future<UserCredential> linkWithCredential(OAuthCredential credential) async {
    final cred = await _auth.currentUser?.linkWithCredential(credential);
    await cred?.user?.getIdToken(true);
    return cred!;
  }

  // The onCreate trigger that assigns the `role: authenticated` claim Supabase
  // needs is async for anonymous users (blocking functions don't cover them),
  // so poll briefly for it before writing to Supabase as this user.
  Future<void> _waitForAuthenticatedClaim(User? user) async {
    if (user == null) return;
    for (var attempt = 0; attempt < 6; attempt++) {
      final result = await user.getIdTokenResult(true);
      if (result.claims?['role'] == 'authenticated') return;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
