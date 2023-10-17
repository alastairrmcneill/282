import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String displayName;

  AppUser({required this.displayName});

  static AppUser? appUserFromFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;

    return AppUser(displayName: firebaseUser.displayName ?? "");
  }
}
