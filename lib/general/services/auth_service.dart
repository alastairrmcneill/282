import 'package:firebase_auth/firebase_auth.dart';
import 'package:two_eight_two/general/models/models.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<AppUser?> get appUserStream {
    return _auth
        .authStateChanges()
        .map((User? user) => user != null ? AppUser.appUserFromFirebaseUser(user) : null);
  }
}
