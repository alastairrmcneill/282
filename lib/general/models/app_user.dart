import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String? uid;
  final String? displayName;

  AppUser({
    this.uid,
    this.displayName,
  });

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      AppUserFields.uid: uid,
      AppUserFields.displayName: displayName,
    };
  }

  static AppUser fromJSON(Map<String, dynamic> json) {
    return AppUser(
      uid: json[AppUserFields.uid] as String?,
      displayName: json[AppUserFields.displayName] as String,
    );
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
    );
  }

  // From firebase
  static AppUser? appUserFromFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;

    return AppUser(uid: firebaseUser.uid);
  }

  @override
  String toString() => 'AppUser(uid: $uid, displayName: $displayName)';
}

class AppUserFields {
  static String uid = 'uid';
  static String displayName = 'displayName';
}
